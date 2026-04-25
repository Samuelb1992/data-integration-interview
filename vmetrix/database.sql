/*
* LocalDb schema
*/

CREATE TABLE BANXICO_SERIES(
  SECURITY_NAME VARCHAR,
  IDSERIE VARCHAR,
  TITULO VARCHAR,
  PERIODICIDAD VARCHAR,
  CIFRA VARCHAR,
  UNIDAD VARCHAR
);

/*
* BANXICO_VALUES — tabla curada de valores diarios por serie.
*
* Granularidad: una fila por (IDSERIE, FECHA).
* Origen: respuesta del endpoint /datos/{start}/{end} de la API SIE Banxico,
* persistida previamente como Parquet RAW en s3_datalake/.
*
* Columnas de negocio:
*   SECURITY_NAME  nombre corto (denormalizado desde BANXICO_SERIES).
*   IDSERIE        identificador Banxico (parte de la PK).
*   FECHA          fecha del valor, ya parseada desde DD/MM/YYYY.
*   VALOR          valor numérico. DECIMAL(18,8) para precisión exacta en
*                  agregaciones (AVG/SUM); cubre tasas, FX y UDIS.
*                  Nullable: la API devuelve 'N/E' en huecos.
*
* Columnas de auditoría:
*   EXECUTION_DATE día en que corrió el pipeline; clave para idempotencia.
*   INGESTED_AT    timestamp exacto del INSERT.
*   SOURCE_FILE    ruta al Parquet RAW que originó la fila.
*   API_FECHA_RAW  fecha tal cual vino de la API (DD/MM/YYYY) para auditoría.
*/
CREATE TABLE BANXICO_VALUES(
  SECURITY_NAME   VARCHAR     NOT NULL,
  IDSERIE         VARCHAR     NOT NULL,
  FECHA           DATE        NOT NULL,
  VALOR           DECIMAL(18, 8),
  EXECUTION_DATE  DATE        NOT NULL,
  INGESTED_AT     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  SOURCE_FILE     VARCHAR,
  API_FECHA_RAW   VARCHAR,
  PRIMARY KEY (IDSERIE, FECHA)
);