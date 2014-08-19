-- Hive script for DEBS usacase

--   Fields:
-- * id – a unique identifier of the measurement [STRING]
-- * timestamp – timestamp of measurement (number of seconds since January 1, 1970, 00:00:00 GMT) [BIGINT]
-- * value – the measurement [FLOAT]
-- * property – type of the measurement: 0 for work or 1 for load [INT]
-- * plug_id – a unique identifier (within a household) of the smart plug [STRING]
-- * household_id – a unique identifier of a household (within a house) where the plug is located [STRING]
-- * house_id – a unique identifier of a house where the household with the plug is located [STRING] 

CREATE EXTERNAL TABLE IF NOT EXISTS DEBSCassandraTable (key STRING, id STRING, time_stamp BIGINT, value FLOAT, property INT,
	plug_id STRING, household_id STRING, house_id STRING, publisher STRING) STORED BY 
'org.apache.hadoop.hive.cassandra.CassandraStorageHandler' WITH SERDEPROPERTIES (
"wso2.carbon.datasource.name" = "WSO2BAM_CASSANDRA_EVENT_SOURCE",
"cassandra.cf.name" = "debs_data",
"cassandra.columns.mapping" = ":key,payload_id,payload_timestamp,payload_value,payload_property,payload_plug_id,payload_household_id,payload_house_id,meta_publisher" );                                   

-- ---------  Query 1 - Houses/households using more than 28 units  -----------------------------------------------------------------------------------------------------------------------

CREATE EXTERNAL TABLE IF NOT EXISTS DEBSTable1(id STRING, household_id STRING, house_id STRING, value FLOAT, time_stamp STRING ) 
STORED BY 'org.wso2.carbon.hadoop.hive.jdbc.storage.JDBCStorageHandler' TBLPROPERTIES ( 
'wso2.carbon.datasource.name'='WSO2BAM_DATASOURCE',
'hive.jdbc.update.on.duplicate' = 'true',
'hive.jdbc.primary.key.fields' = 'id',
'hive.jdbc.table.create.query' = 'CREATE TABLE DEBS_Table_1 ( id VARCHAR(50), household_id VARCHAR(50), house_id VARCHAR(50), value FLOAT, time_stamp VARCHAR(50))' );

insert overwrite table DEBSTable1 select id, household_id, house_id, value, from_unixtime(time_stamp, 'yyyy-MM-dd HH:mm:ss') as time_stamp from DEBSCassandraTable where property = 1 AND value > 28 group by id, household_id, house_id, value, from_unixtime(time_stamp, 'yyyy-MM-dd HH:mm:ss');

-- ---------  Query 2 - Households with more than 3 plugs  -----------------------------------------------------------------------------------------------------------------------