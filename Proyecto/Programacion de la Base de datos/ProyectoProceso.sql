CREATE OR REPLACE PACKAGE SERVIU IS
    PROCEDURE PROCESO_SERVIU;
    FUNCTION CARGAS_POST(RUN VARCHAR2) RETURN NUMBER;
    FUNCTION ESTADOCIVIL_POST(RUN VARCHAR2) RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY SERVIU IS
    PROCEDURE PROCESO_SERVIU AS
V_EDAD NUMBER(8);
V_PUNTAJECARGAS NUMBER(8);
V_CARGAS NUMBER(8);
V_PUNTAJEEDAD NUMBER(8);
V_ESTADOCIVIL estado_civil.nombre_estado%TYPE;
V_PUNTAJECIVIL NUMBER(8);
V_PUEBLOINDIGENA pueblo_indigena.nombre_pueblo%TYPE;
V_PUNTAJEINDIGENA NUMBER(8);
V_PUNTAJEAHORRO NUMBER(8);
V_MONTOAHORRO NUMBER(12);
V_TITULO VARCHAR2(100);
V_PUNTAJETITULO NUMBER(8);
v_total number(9);
CURSOR C_FICHA IS SELECT * FROM FICHA_POSTULACION;
BEGIN
    FOR R_FICHA IN C_FICHA LOOP
    DECLARE
    CURSOR C_POSTULANTE IS SELECT * FROM POSTULANTE WHERE R_FICHA.RUT_POSTULANTE = RUT_POSTULANTE;
    R_POSTULANTE C_POSTULANTE%ROWTYPE;
    BEGIN
    OPEN C_POSTULANTE;
    LOOP
    FETCH C_POSTULANTE INTO R_POSTULANTE;
    EXIT WHEN C_POSTULANTE%NOTFOUND;
        BEGIN
        SELECT COUNT(RUT_CARGA) INTO V_CARGAS FROM CARGAS_FAMILIAR WHERE RUT_POSTULANTE = R_POSTULANTE.RUT_POSTULANTE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SENTENCIA NO RECUPERA FILA ');
        V_CARGAS:=0;
        END;
        BEGIN
        SELECT PUNTOS_CARGA INTO V_PUNTAJECARGAS FROM TRAMO_CARGAS WHERE V_CARGAS BETWEEN TRAMO_INF AND TRAMO_SUP;
        EXCEPTION
        WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('SENTENCIA RECUPERA MAS DE UNA FILA ');
        V_PUNTAJECARGAS:=0;
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SENTENCIA NO RECUPERA FILA '); 
        V_PUNTAJECARGAS:=0;
        END;
        BEGIN
        SELECT TRUNC((SYSDATE-FECNAC_POSTULANTE)/365) INTO V_EDAD FROM POSTULANTE WHERE RUT_POSTULANTE = R_POSTULANTE.RUT_POSTULANTE;
        END;
        BEGIN
        SELECT PUNTOS_EDAD INTO V_PUNTAJEEDAD FROM TRAMO_EDADES WHERE V_EDAD BETWEEN TRAMO_INF AND TRAMO_SUP;
        EXCEPTION
        WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('SENTENCIA RECUPERA MAS DE UNA FILA ');
        V_PUNTAJEEDAD:=0;
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SENTENCIA NO RECUPERA FILA '); 
        V_PUNTAJEEDAD:=0;
        END;
        BEGIN
        SELECT NOMBRE_ESTADO,PUNTAJE_ECIVIL INTO V_ESTADOCIVIL,V_PUNTAJECIVIL FROM ESTADO_CIVIL WHERE ID_ESTADOCIVIL = R_POSTULANTE.ID_ESTADOCIVIL;
        END;
        BEGIN
        SELECT NOMBRE_PUEBLO,PUNTAJE_PUEBLO INTO V_PUEBLOINDIGENA,V_PUNTAJEINDIGENA FROM PUEBLO_INDIGENA WHERE ID_PUEBLO = R_POSTULANTE.ID_PUEBLO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_PUEBLOINDIGENA:='NO';
            V_PUNTAJEINDIGENA:=0;
        END;
        BEGIN
        SELECT
        ah.monto_ahorrado,th.puntos_ahorro into V_MONTOAHORRO,V_PUNTAJEAHORRO
        FROM AHORRO AH JOIN TRAMO_AHORRO TH
        ON AH.MONTO_AHORRADO BETWEEN TH.TRAMO_INF AND TH.TRAMO_SUP
        where ah.id_ficha=R_FICHA.ID_FICHA;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_MONTOAHORRO:=0;
            V_PUNTAJEAHORRO:=0;
        END;
        BEGIN
        SELECT tl.descripcion_titulo,tp.puntaje_tipo INTO V_TITULO,V_PUNTAJETITULO
        FROM ACREDITACION AC JOIN TITULO TL
        ON ac.id_titulo = tl.id_titulo JOIN titulo_tipo TP
        ON tp.id_tipo_titulo = tl.id_tipo_titulo
        WHERE ac.id_ficha=R_FICHA.ID_FICHA;
        END;
        DBMS_OUTPUT.put_line(R_FICHA.ID_FICHA||' - '||R_POSTULANTE.RUT_POSTULANTE||' - '||V_CARGAS||' '||V_PUNTAJECARGAS||' EDAD '||V_EDAD||' PUNTAJE :'||V_PUNTAJEEDAD||' ESTADO CIVIL :'||V_ESTADOCIVIL||' PUNTAJE :'||V_PUNTAJECIVIL||' PUEBLO INDIGENA '||V_PUEBLOINDIGENA||' PUNTAJE :'||V_PUNTAJEINDIGENA||' MONTO AHORRO :'||v_montoahorro||' PUNTAJE :'||v_puntajeahorro);
        DBMS_OUTPUT.PUT_LINE('Titulo :'||V_TITULO||' Puntaje titulo :'||v_puntajetitulo);
        v_total:=v_puntajeahorro+v_puntajecargas+v_puntajecivil+v_puntajeedad+v_puntajeindigena+v_puntajetitulo;
        INSERT INTO PROCESO VALUES (SEQ_PROCESO.nextval,R_FICHA.ANNO_POSTULACION,r_postulante.rut_postulante,v_edad,v_puntajeedad,v_cargas,v_puntajecargas,v_estadocivil,v_puntajecivil,v_puebloindigena,v_puntajeindigena,v_montoahorro,v_puntajeahorro,v_titulo,v_puntajetitulo,v_total,r_ficha.id_ficha);
    END LOOP;
    CLOSE C_POSTULANTE;
    END;
    END LOOP;
END;
    FUNCTION CARGAS_POST(RUN VARCHAR2) RETURN NUMBER IS
V_CARGAS NUMBER;
BEGIN
    SELECT COUNT(*) INTO V_CARGAS FROM CARGAS_FAMILIAR WHERE RUT_POSTULANTE = RUN;
    RETURN V_CARGAS;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    V_CARGAS:=0;
    RETURN V_CARGAS;
    WHEN OTHERS THEN
    V_CARGAS:=0;
END;
FUNCTION ESTADOCIVIL_POST(RUN VARCHAR2) RETURN VARCHAR2 IS
V_ESTADO VARCHAR2(30);
BEGIN
    SELECT NOMBRE_ESTADO INTO V_ESTADO FROM estado_civil E JOIN POSTULANTE P ON P.ID_ESTADOCIVIL = E.ID_ESTADOCIVIL WHERE RUT_POSTULANTE = RUN;
    RETURN V_ESTADO;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 'No se encontro estado civil del postulante';
    WHEN OTHERS THEN
    RETURN 'Error con el estado civil del postulante';
END;
END;