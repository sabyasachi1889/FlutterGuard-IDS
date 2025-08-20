-- Location: supabase/migrations/20250820071059_flutterguard_ids_security_monitoring.sql
-- Schema Analysis: Fresh project - no existing tables
-- Integration Type: Complete new security monitoring system
-- Dependencies: None (fresh project)

-- 1. Extensions & Types
CREATE TYPE public.user_role AS ENUM ('admin', 'security_analyst', 'viewer');
CREATE TYPE public.alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE public.alert_type AS ENUM ('port_scan', 'brute_force', 'anomaly', 'malware', 'ddos', 'intrusion');
CREATE TYPE public.monitoring_status AS ENUM ('active', 'inactive', 'paused', 'error');
CREATE TYPE public.log_level AS ENUM ('info', 'warning', 'error', 'critical');

-- 2. Core Tables
-- Critical intermediary table for user profiles
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'viewer'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Monitoring sessions table
CREATE TABLE public.monitoring_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status public.monitoring_status DEFAULT 'active'::public.monitoring_status,
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMPTZ,
    packets_analyzed BIGINT DEFAULT 0,
    threats_detected INTEGER DEFAULT 0,
    bandwidth_used DECIMAL(10,2) DEFAULT 0,
    active_connections INTEGER DEFAULT 0,
    session_notes TEXT
);

-- Network alerts table
CREATE TABLE public.security_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.monitoring_sessions(id) ON DELETE CASCADE,
    alert_type public.alert_type NOT NULL,
    severity public.alert_severity NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    source_ip INET,
    target_ip INET,
    port INTEGER,
    is_resolved BOOLEAN DEFAULT false,
    resolved_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Network traffic logs
CREATE TABLE public.network_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.monitoring_sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    source_ip INET NOT NULL,
    destination_ip INET NOT NULL,
    source_port INTEGER,
    destination_port INTEGER,
    protocol TEXT NOT NULL,
    packet_size INTEGER,
    log_level public.log_level DEFAULT 'info'::public.log_level,
    raw_data JSONB,
    is_suspicious BOOLEAN DEFAULT false
);

-- System metrics table
CREATE TABLE public.system_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.monitoring_sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    cpu_usage DECIMAL(5,2),
    memory_usage DECIMAL(5,2),
    disk_usage DECIMAL(5,2),
    network_throughput DECIMAL(10,2),
    active_connections INTEGER,
    packets_per_second INTEGER
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_monitoring_sessions_user_id ON public.monitoring_sessions(user_id);
CREATE INDEX idx_monitoring_sessions_status ON public.monitoring_sessions(status);
CREATE INDEX idx_security_alerts_session_id ON public.security_alerts(session_id);
CREATE INDEX idx_security_alerts_severity ON public.security_alerts(severity);
CREATE INDEX idx_security_alerts_created_at ON public.security_alerts(created_at);
CREATE INDEX idx_network_logs_session_id ON public.network_logs(session_id);
CREATE INDEX idx_network_logs_timestamp ON public.network_logs(timestamp);
CREATE INDEX idx_network_logs_source_ip ON public.network_logs(source_ip);
CREATE INDEX idx_system_metrics_session_id ON public.system_metrics(session_id);
CREATE INDEX idx_system_metrics_timestamp ON public.system_metrics(timestamp);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'viewer')::public.user_role
  );  
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_monitoring_session_stats()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Update session stats when new alert or log is added
        IF TG_TABLE_NAME = 'security_alerts' THEN
            UPDATE public.monitoring_sessions 
            SET threats_detected = threats_detected + 1
            WHERE id = NEW.session_id;
        ELSIF TG_TABLE_NAME = 'network_logs' THEN
            UPDATE public.monitoring_sessions 
            SET packets_analyzed = packets_analyzed + 1
            WHERE id = NEW.session_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monitoring_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.network_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_metrics ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Using Updated 7-Pattern System)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for monitoring sessions
CREATE POLICY "users_manage_own_monitoring_sessions"
ON public.monitoring_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 7: Complex relationship - Security analysts can view all alerts
CREATE OR REPLACE FUNCTION public.can_view_security_data()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role IN ('admin', 'security_analyst')
    AND up.is_active = true
)
$$;

CREATE POLICY "security_analysts_view_all_alerts"
ON public.security_alerts
FOR SELECT
TO authenticated
USING (public.can_view_security_data());

CREATE POLICY "users_manage_session_alerts"
ON public.security_alerts
FOR ALL
TO authenticated
USING (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
);

-- Network logs - analysts can view all, users can view own session logs
CREATE POLICY "security_analysts_view_all_logs"
ON public.network_logs
FOR SELECT
TO authenticated
USING (public.can_view_security_data());

CREATE POLICY "users_manage_session_logs"
ON public.network_logs
FOR ALL
TO authenticated
USING (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
);

-- System metrics - same pattern
CREATE POLICY "security_analysts_view_all_metrics"
ON public.system_metrics
FOR SELECT
TO authenticated
USING (public.can_view_security_data());

CREATE POLICY "users_manage_session_metrics"
ON public.system_metrics
FOR ALL
TO authenticated
USING (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    session_id IN (
        SELECT id FROM public.monitoring_sessions 
        WHERE user_id = auth.uid()
    )
);

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_security_alert_created
  AFTER INSERT ON public.security_alerts
  FOR EACH ROW EXECUTE FUNCTION public.update_monitoring_session_stats();

CREATE TRIGGER on_network_log_created
  AFTER INSERT ON public.network_logs
  FOR EACH ROW EXECUTE FUNCTION public.update_monitoring_session_stats();

-- 8. Complete Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    analyst_uuid UUID := gen_random_uuid();
    viewer_uuid UUID := gen_random_uuid();
    session1_id UUID := gen_random_uuid();
    session2_id UUID := gen_random_uuid();
    alert1_id UUID := gen_random_uuid();
    alert2_id UUID := gen_random_uuid();
    alert3_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@flutterguard.com', crypt('FlutterGuard2024!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (analyst_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'analyst@flutterguard.com', crypt('FlutterGuard2024!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Security Analyst", "role": "security_analyst"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (viewer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'viewer@flutterguard.com', crypt('FlutterGuard2024!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Network Viewer", "role": "viewer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create monitoring sessions
    INSERT INTO public.monitoring_sessions (id, user_id, status, started_at, packets_analyzed, threats_detected, bandwidth_used, active_connections)
    VALUES
        (session1_id, admin_uuid, 'active'::public.monitoring_status, now() - interval '2 hours', 15420, 3, 245.67, 18),
        (session2_id, analyst_uuid, 'inactive'::public.monitoring_status, now() - interval '6 hours', 8750, 1, 123.45, 0);

    -- Create security alerts
    INSERT INTO public.security_alerts (id, session_id, alert_type, severity, title, description, source_ip, target_ip, port, created_at)
    VALUES
        (alert1_id, session1_id, 'port_scan'::public.alert_type, 'critical'::public.alert_severity, 
         'Suspicious Port Scan Detected', 'Multiple connection attempts from unknown IP address targeting common service ports.',
         '192.168.1.105', '10.0.0.1', 22, now() - interval '2 minutes'),
        (alert2_id, session1_id, 'anomaly'::public.alert_type, 'high'::public.alert_severity,
         'Unusual Bandwidth Usage', 'Abnormal data transfer detected from internal device to external server.',
         '10.0.0.23', '203.0.113.45', 443, now() - interval '15 minutes'),
        (alert3_id, session2_id, 'brute_force'::public.alert_type, 'medium'::public.alert_severity,
         'Failed Authentication Attempts', 'Multiple failed login attempts detected on network service.',
         '172.16.0.45', '10.0.0.1', 80, now() - interval '1 hour');

    -- Create network logs
    INSERT INTO public.network_logs (session_id, source_ip, destination_ip, source_port, destination_port, protocol, packet_size, is_suspicious, timestamp)
    VALUES
        (session1_id, '192.168.1.100', '8.8.8.8', 5432, 53, 'UDP', 512, false, now() - interval '30 seconds'),
        (session1_id, '192.168.1.105', '10.0.0.1', 34567, 22, 'TCP', 64, true, now() - interval '2 minutes'),
        (session1_id, '10.0.0.23', '203.0.113.45', 49152, 443, 'TCP', 1024, true, now() - interval '15 minutes'),
        (session2_id, '172.16.0.45', '10.0.0.1', 54321, 80, 'TCP', 256, true, now() - interval '1 hour');

    -- Create system metrics
    INSERT INTO public.system_metrics (session_id, cpu_usage, memory_usage, disk_usage, network_throughput, active_connections, packets_per_second, timestamp)
    VALUES
        (session1_id, 45.2, 67.8, 23.1, 125.4, 18, 87, now() - interval '1 minute'),
        (session1_id, 52.1, 72.3, 23.2, 134.7, 19, 92, now() - interval '2 minutes'),
        (session2_id, 23.4, 34.5, 45.6, 67.8, 12, 34, now() - interval '30 minutes');

END $$;
