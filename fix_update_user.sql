-- Phiên bản đơn giản - không query DBA_USERS
-- Yêu cầu phải truyền tablespace_name khi update quota

CREATE OR REPLACE PROCEDURE SP_UPDATE_USER (
    p_username          IN VARCHAR2,
    p_password          IN VARCHAR2 DEFAULT NULL,
    p_default_ts        IN VARCHAR2 DEFAULT NULL,
    p_temp_ts           IN VARCHAR2 DEFAULT NULL,
    p_profile           IN VARCHAR2 DEFAULT NULL,
    p_quota             IN VARCHAR2 DEFAULT NULL,
    p_quota_tablespace  IN VARCHAR2 DEFAULT NULL  -- Tablespace cho quota
)
AUTHID CURRENT_USER
AS
    v_sql VARCHAR2(1000);
BEGIN
    IF p_password IS NOT NULL THEN
        v_sql := 'ALTER USER "' || p_username || '" IDENTIFIED BY "' || p_password || '"';
        EXECUTE IMMEDIATE v_sql;
    END IF;
    
    IF p_default_ts IS NOT NULL THEN
        v_sql := 'ALTER USER "' || p_username || '" DEFAULT TABLESPACE "' || p_default_ts || '"';
        EXECUTE IMMEDIATE v_sql;
    END IF;
    
    IF p_temp_ts IS NOT NULL THEN
        v_sql := 'ALTER USER "' || p_username || '" TEMPORARY TABLESPACE "' || p_temp_ts || '"';
        EXECUTE IMMEDIATE v_sql;
    END IF;
    
    IF p_profile IS NOT NULL THEN
        v_sql := 'ALTER USER "' || p_username || '" PROFILE "' || p_profile || '"';
        EXECUTE IMMEDIATE v_sql;
    END IF;
    
    -- Xử lý Quota - cần có tablespace
    IF p_quota IS NOT NULL THEN
        -- Ưu tiên p_quota_tablespace, rồi đến p_default_ts
        IF p_quota_tablespace IS NOT NULL THEN
            IF UPPER(p_quota) = 'UNLIMITED' THEN
                v_sql := 'ALTER USER "' || p_username || '" QUOTA UNLIMITED ON "' || p_quota_tablespace || '"';
            ELSE
                v_sql := 'ALTER USER "' || p_username || '" QUOTA ' || p_quota || ' ON "' || p_quota_tablespace || '"';
            END IF;
            EXECUTE IMMEDIATE v_sql;
        ELSIF p_default_ts IS NOT NULL THEN
            IF UPPER(p_quota) = 'UNLIMITED' THEN
                v_sql := 'ALTER USER "' || p_username || '" QUOTA UNLIMITED ON "' || p_default_ts || '"';
            ELSE
                v_sql := 'ALTER USER "' || p_username || '" QUOTA ' || p_quota || ' ON "' || p_default_ts || '"';
            END IF;
            EXECUTE IMMEDIATE v_sql;
        END IF;
    END IF;
END SP_UPDATE_USER;
/

SELECT object_name, status FROM user_objects WHERE object_name = 'SP_UPDATE_USER';
