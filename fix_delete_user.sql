-- Kết nối vào CDB để grant quyền
-- Chạy file này bằng: sqlplus / as sysdba

-- Grant quyền SELECT trên V$SESSION cho SYSTEM trong PDB
ALTER SESSION SET CONTAINER = FREEPDB1;

GRANT SELECT ON SYS.V_$SESSION TO SYSTEM;
GRANT ALTER SYSTEM TO SYSTEM;

-- Tạo lại procedure với khả năng kill sessions
CREATE OR REPLACE PROCEDURE SYSTEM.SP_DELETE_USER (
    p_username IN VARCHAR2
)
AUTHID CURRENT_USER
AS
    v_sql VARCHAR2(500);
    v_count NUMBER := 0;
BEGIN
    -- Đếm và kill sessions
    FOR sess IN (
        SELECT SID, SERIAL# 
        FROM SYS.V_$SESSION 
        WHERE UPPER(USERNAME) = UPPER(p_username)
    ) LOOP
        BEGIN
            v_sql := 'ALTER SYSTEM KILL SESSION ''' || sess.SID || ',' || sess.SERIAL# || ''' IMMEDIATE';
            EXECUTE IMMEDIATE v_sql;
            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
    
    -- Drop user
    EXECUTE IMMEDIATE 'DROP USER "' || p_username || '" CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1940 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Khong the xoa user vi con session dang hoat dong. Da thu kill ' || v_count || ' sessions.');
        ELSE
            RAISE;
        END IF;
END SP_DELETE_USER;
/

SELECT object_name, status FROM dba_objects WHERE object_name = 'SP_DELETE_USER' AND owner = 'SYSTEM';
