/*
    
    db_structure.sql created from structure.xml version 0.2
    version 0.2
    
    Contains the database structure for QRAP.

QRap is licensed under the GNU General Public License version 3
www.QRap.org.za
*/

-- machine
CREATE SEQUENCE machine_id_seq;
CREATE TABLE IF NOT EXISTS machine (
	id 						smallint primary key unique not null default nextval('machine_id_seq'),
	lastmodified	timestamp without time zone,
	qrapinst 			varchar(12),
	mainuserid 		integer
);
CREATE OR REPLACE VIEW machine_view AS select * from machine;

-- Server Updates
CREATE TABLE IF NOT EXISTS serverupdates (
	id 				serial primary key unique not null,
	machineid	smallint references machine(id),
	update 		timestamp without time zone
);
CREATE OR REPLACE VIEW serverupdates_view AS select * from serverupdates;
  
-- Site
CREATE TABLE IF NOT EXISTS site (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	sitename 			text,
	status 				varchar(30),
	location 			geography(POINT,4326),
	groundheight 	integer
);
CREATE OR REPLACE VIEW site_view AS select * from site;
CREATE OR REPLACE VIEW site_view_only AS select * from site;
CREATE OR REPLACE VIEW site_view_list AS select * from site;

-- Site description
CREATE TABLE IF NOT EXISTS sitedescription ( 
	id 								serial primary key unique not null,
	lastmodified 			timestamp without time zone,
	machineid 				smallint references machine(id),
	siteid 						integer references site(id) on delete cascade,
	physicaladdress 	text,
	structuretype 		varchar(20),
	structureheight 	real,
	structurecapacity varchar(100),
	availablecapacity	varchar(100),
	powersupply 			varchar(12),
	containertype 		varchar(15),
	fencing 					varchar(50),
	access 						text,
	comments 					text,
	sitedocumentation text,
	existing_mast 		boolean,
	min_mast_height 	integer,
	max_mast_height 	integer
);
CREATE OR REPLACE VIEW sitedescription_view AS select * from sitedescription;

-- Site contacts
CREATE TABLE IF NOT EXISTS sitecontacts (
	id 										serial primary key unique not null,
	lastmodified 					timestamp without time zone,
	machineid 						smallint references machine(id),
	siteid 								integer references site(id) on delete cascade,
	ownername 						varchar(100),
	naturalperson 				boolean,
	contactname 					varchar(100),
	postaladdress 				text,
	tel 									varchar(20),
	email 								varchar(200),
	idnumber 							char(13),
	contract 							varchar(50),
	contractstartdate 		date,
	contractenddate 			date,
	monthlyrental 				numeric(15,2),
	electricitysupplier 	varchar(30),
	electricityaccno 			varchar(20),
	electricitypoleno 		varchar(15),
	electricityemergency	varchar(20)
);
CREATE OR REPLACE VIEW sitecontacts_view AS select * from sitecontacts;

-- File sets to use
CREATE SEQUENCE filesetsused_id_seq;
CREATE TABLE IF NOT EXISTS filesetsused (
	id 						smallint primary key unique not null default nextval('filesetsused_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	type 					varchar(20),
	orderarray 		smallint[]
);
CREATE OR REPLACE VIEW filesetsused_view AS select * from filesetsused;

-- BTL
CREATE TABLE IF NOT EXISTS btl (
	id 						serial primary key unique not null,
	lastmodified 	timestamp without time zone,
	machineid 		smallint references machine(id),
	siteid 				integer references site(id) on delete cascade,
	dtmsource 		smallint references filesetsused(id),
	cluttersource smallint references filesetsused(id),
	antennaheight	real,
	mobileheight 	real,
	frequency 		real constraint btl_freq check (frequency > 0),
	kfactor 			real,
	radius 				real constraint btl_radius check (radius > 0),
	numangles 		integer constraint numangles check (numangles > 2),
	distanceres 	real,
	btlplot 			text,	
	maxr 					boolean
);

-- Technology
CREATE SEQUENCE technology_id_seq;
CREATE TABLE IF NOT EXISTS technology (
	id 							smallint primary key unique not null default nextval('technology_id_seq'),		
 	lastmodified 		timestamp without time zone,
	machineid 			smallint references machine(id),
	technologytype	varchar(20),
	startfreq 			real constraint tech_start_freq check (startfreq > 0),
	stopfreq 				real constraint tech_stop_freq check (stopfreq > 0),
	btlfreq 				real constraint tech_btl_freq check (btlfreq > 0),
	spacing 				real,
	bandwidth 			real,
	uplink 					real,
	downlink 				real,
	maxpathloss 		real,
	maxrange 				real,
	rxmin 					real,
	cico 						real,
	ciad 						real,
	fademargin 			real,
	ebno 						real,
	description 		text,
	defaultsite 		integer references site(id) on delete cascade,
	DistRes 				real
);
CREATE OR REPLACE VIEW	technology_view AS select * from technology;
	
-- Spectral Envelopes
CREATE SEQUENCE envelopes_id_seq;
CREATE TABLE IF NOT EXISTS envelopes (
	id 						smallint primary key unique not null default nextval('envelopes_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	envelopetype 	varchar(30),
	techkey 			smallint references technology(id),
	offsets 			real[],
	values 				real[],
	numpoints 		integer
);
CREATE OR REPLACE VIEW envelopes_view AS select * from envelopes;

-- Equipment type
CREATE TABLE IF NOT EXISTS equipmenttype (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	devicename 		varchar(150),
	techkey 			smallint references technology(id),
	manufacturer 	varchar(30),
	faccode 			varchar(50),
	description 	text,
	cost 					numeric(12,2)
);
CREATE OR REPLACE VIEW equipmenttype_view AS select * from equipmenttype;

-- Antenna devices
CREATE TABLE IF NOT EXISTS antennadevice (
	id 						serial primary key unique not null,
	lastmodified 	timestamp without time zone,
	machineid 		smallint references machine(id),
	devicename 		varchar(50),
	manufacturer	varchar(100),
	faccode 			varchar(50),
	electilt 			boolean,
	description 	text,
	cost 					numeric(12,2)
);
CREATE OR REPLACE VIEW antennadevice_view AS select * from antennadevice;
	
-- Antenna patterns
CREATE TABLE IF NOT EXISTS antennapattern (
	id 								serial primary key unique not null,
	lastmodified 			timestamp without time zone,
	machineid 				smallint references machine(id),
	antdevicekey 			integer references antennadevice(id),
	patternfile 			varchar(100),
	techkey 					smallint references technology(id),
	description 			text,
	frequency 				real,
	gain 							real,
	azibeamwidth 			real,
	elevbeamwidth 		real,		
	fronttoback 			real,
	polarization 			varchar(12),
	numazipoints 			smallint,
	numelevpoints 		smallint,
	azimuthangles 		real[],
	azimuthpattern 		real[],
	elevationangles 	real[],
	elevationpattern	real[]
);
CREATE OR REPLACE VIEW antennapattern_view AS select * from antennapattern;

-- Projects
CREATE SEQUENCE projects_id_seq;
CREATE TABLE IF NOT EXISTS projects (
	id 						smallint primary key unique not null default nextval('projects_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	projectname 	varchar(20),
	description 	text
);
CREATE OR REPLACE VIEW projects_view AS select * from projects;

-- FlagX
CREATE SEQUENCE flagx_id_seq;
CREATE TABLE IF NOT EXISTS flagx (
	id 						smallint primary key unique not null default nextval('flagx_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	shortname 		varchar(20),
	description 	text
);
CREATE OR REPLACE VIEW flagx_view AS select * from flagx;

-- FlagZ
CREATE SEQUENCE flagz_id_seq;
CREATE TABLE flagz (
	id 						smallint primary key unique not null default nextval('flagz_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	shortname 		varchar(20),
	description 	text
);
CREATE OR REPLACE VIEW flagz_view AS select * from flagz;

-- Radio Installation
CREATE TABLE IF NOT EXISTS radioinstallation (
	id 							serial primary key unique not null,
	lastmodified 		timestamp without time zone,
	machineid 			smallint references machine(id),
	siteid 					integer references site(id) on delete cascade,
	sector 					integer,
	permanent 			boolean,
	techkey 				smallint references technology(id),
	eirp 						real,
	diversity 			boolean,
	txpower 				real,
	txlosses 				real,
	txantennaheight real,
	txantpatternkey integer references antennapattern(id),
	txbearing 			real,
	txmechtilt 			real,
	rxsensitivity 	real,
	rxlosses 				real,
	rxantennaheight real,
	rxantpatternkey	integer references antennapattern(id),
	rxbearing 			real,		
	rxmechtilt 			real,
	btlplot 				integer,
	project 				smallint references projects(id),
	flagx 					smallint references flagx(id),		
	flagz 					smallint references flagz(id)
);
CREATE OR REPLACE VIEW radioinstallation_view AS select distinct sitename, sitename||sector as sectorname, 
							radioinstallation.* from radioinstallation cross join site where siteid=site.id;

-- Mobile installation
CREATE TABLE IF NOT EXISTS mobile (
	id 						serial primary key unique not null,
	lastmodified 	timestamp without time zone,
	machineid 		smallint references machine(id),
	mobileheight	real,
	name 					varchar(30),
	techkey 			smallint references technology(id),
	txpower 			real,
	txlosses 			real,
	eirp 					real,
	diversity 		boolean,
	rxsensitivity real,
	rxlosses 			real,
	antpatternkey integer references antennapattern(id)
);
CREATE OR REPLACE VIEW mobile_view AS select * from mobile;

-- Antennas
CREATE TABLE IF NOT EXISTS antenna (
	id 								serial primary key unique not null,
	lastmodified 			timestamp without time zone,
	machineid 				smallint references machine(id),
	serialnumber 			varchar(150),
	rikey 						integer references radioinstallation(id) on delete cascade,
	antdevicekey 			integer references antennadevice(id),
	installationdate	date
);
CREATE OR REPLACE VIEW antenna_view AS select 
				antenna.id as id,
				site.sitename as sitename,
				antenna.serialnumber as serialnumber,
				antenna.rikey as rikey,
				antenna.antdevicekey as antdevicekey,
				antenna.installationdate as installationdate
				from antenna, radioinstallation, site 
				where (antenna.rikey=radioinstallation.id and radioinstallation.siteid=site.id )
				
				union
				
				select	antenna.id as id,
				null as sitename,
				antenna.serialnumber as serialnumber,
				antenna.rikey as rikey,
				antenna.antdevicekey as antdevicekey,
				antenna.installationdate as installationdate
				from antenna where antenna.rikey is null;
	
-- Equipment
CREATE TABLE IF NOT EXISTS equipment (
	id 								serial primary key unique not null,
	lastmodified 			timestamp without time zone,
	machineid 				smallint references machine(id),
	serialnumber 			text,
	rikey 						integer references radioinstallation(id) on delete cascade,
	equipkey 					integer references equipmenttype(id),
	installationdate	date
);
CREATE OR REPLACE VIEW equipment_view AS select 
				equipment.id as id,
				site.sitename as sitename,
				equipment.serialnumber as serialnumber,
				equipment.rikey as rikey,
				equipment.equipkey as equipkey,
				equipment.installationdate as installationdate
				from equipment, radioinstallation,site 
				where (equipment.rikey=radioinstallation.id and radioinstallation.siteid=site.id )
				
				union
				
				select	equipment.id as id,
				null as sitename,
				equipment.serialnumber as serialnumber,
				equipment.rikey as rikey,
				equipment.equipkey as equipkey,
				equipment.installationdate as installationdate
				from equipment where equipment.rikey is null;

-- Cell
CREATE TABLE IF NOT EXISTS cell (
	id 							serial primary key unique not null,
	lastmodified 		timestamp without time zone,
	machineid 			smallint references machine(id),
	mastercell 			integer references cell(id) on delete cascade,
	risector 				integer references radioinstallation(id) on delete cascade,
	permanent 			boolean,
	cstraffic 			real,
	pstraffic 			real,
	txpower 				real,
	beacon 					integer,
	layerthreshold	integer,
	centriod 				POINT
);
CREATE OR REPLACE VIEW cell_view AS select 
				cell.id as id,
				sitename||sector as sectorname,
				cell.id||sitename||sector as cellname,
				cell.risector as risector,
				cell.mastercell as mastercell,
				cell.permanent as permanent,
				cell.cstraffic as cstraffic,
				cell.pstraffic as pstraffic,
				cell.centriod as centriod,
				cell.txpower as txpower,
				cell.beacon as beacon,
				cell.layerthreshold as layerthreshold
				from site, radioinstallation, cell
				where (cell.risector = radioinstallation.id 
				and radioinstallation.siteid = site.id);

-- Frequency allocation list
CREATE TABLE IF NOT EXISTS frequencyallocationlist (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	ci 						integer references cell(id) on delete cascade,
	carrier 			integer,
	channel 			integer
);
CREATE OR REPLACE VIEW frequencyallocationlist_view AS select 
					frequencyallocationlist.id as id,
					frequencyallocationlist.ci as ci, cell_view.cellname as cellname,
					frequencyallocationlist.carrier as carrier,
					frequencyallocationlist.channel as channel 
					from frequencyallocationlist, cell_view
					where (frequencyallocationlist.ci=cell_view.id );

-- Cell Parameters
CREATE TABLE IF NOT EXISTS cellparameters (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	techkey 			smallint references technology(id),
	parametername varchar(50),
	type 					varchar(30),
	defaultseting varchar(33),
	minimum 			varchar(33),
	maximum 			varchar(33),
	description 	text
);
CREATE OR REPLACE VIEW cellparameters_view AS select * from cellparameters;

-- Cell Parameters Settings
CREATE TABLE IF NOT EXISTS parametersettings (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	ci 						integer references cell(id) on delete cascade,
	parameterid 	integer references cellparameters(id) on delete cascade,
	setting 			varchar(33)
);
CREATE OR REPLACE VIEW parametersettings_view AS select 
					parametersettings.id as id,
					parametersettings.ci as ci, cell_view.cellname as cellname,
					parametername as cell_parameter, parametersettings.setting as setting
					from parametersettings, cell_view, cellparameters 
					where (parametersettings.ci=cell_view.id 
					and parameterid=cellparameters.id);

-- Links
CREATE TABLE IF NOT EXISTS links (
	id 						serial primary key unique not null,
	lastmodified 	timestamp without time zone,
	machineid 		smallint references machine(id),
	linkname 			varchar(150),
	txinst 				integer references radioinstallation(id) on delete cascade,
	rxinst 				integer references radioinstallation(id) on delete cascade,
	minclearance	real,
	frequency 		real,
	pathloss 			real,
	kfactor 			real,
	line 					geography(LINESTRING,4326),
	status 				varchar(15)
);
CREATE OR REPLACE VIEW links_view AS select links.id as id, linkname, 
			site1.sitename||rad1.sector as txsite, txinst,
			rad1.txbearing as txbearing,
			site2.sitename||rad2.sector as rxsite, rxinst,
			rad2.rxbearing as rxbearing,
			ST_Distance(site1.location, site2.location, true) as Distance,
			minclearance,
			frequency, pathloss, kfactor, line, links.status
			from links cross join radioinstallation as rad1 cross join site_view_only as site1
	 		cross join radioinstallation as rad2 cross join site_view_only as site2
	 		where rad1.id=txinst
			and rxinst=rad2.id
			and rad1.siteid=site1.id
			and rad2.siteid=site2.id;

-- Custom Area Filter
CREATE TABLE IF NOT EXISTS customareafilter (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	areaname 			text,
	the_geom 			POLYGON
);
CREATE OR REPLACE VIEW customareafilter_view AS select * from customareafilter;
	
-- Served key locations
CREATE TABLE IF NOT EXISTS servedkeylocations (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	keylocation 	text,
	location			geography(POINT,4326),
	rikey 				integer references radioinstallation(id) on delete cascade,
	rank 					integer
);
CREATE OR REPLACE VIEW servedkeylocations_view AS select * from servedkeylocations;

-- Colour Management
CREATE TABLE IF NOT EXISTS colourmanagement (
	id 				serial primary key unique not null,
	machineid	smallint references machine(id),
	r 				integer,
	g 				integer,
	b 				integer,
	a 				integer,
	val 			real,
	label 		varchar(50),
	plottype 	varchar(50)
);
CREATE OR REPLACE VIEW colourmanagement_view AS select * from colourmanagement;

-- Classification Group
CREATE TABLE classificationgroup (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	classgroup 		varchar(30),
	description 	text
);
CREATE OR REPLACE VIEW classificationgroup_view AS select * from classificationgroup;

-- Clutter Types
CREATE SEQUENCE cluttertype_id_seq;
CREATE TABLE IF NOT EXISTS cluttertype (
	id 						smallint primary key unique not null default nextval('cluttertype_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	landcoverid 	integer,
	cluttername 	varchar(50),
	description 	text,
	height 				real,
	width 				real,
	classgroup 		integer references classificationgroup(id),
	standardtype 	integer references cluttertype(id)
);
CREATE OR REPLACE VIEW cluttertype_view AS select * from cluttertype;

-- Clutter Tuning Terms
CREATE TABLE IF NOT EXISTS clutterterms (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	term 					varchar(30),
	description 	text
);
CREATE TABLE clutterterms_view AS select * from clutterterms;

-- Tuned Coefficients/Parameters
CREATE TABLE IF NOT EXISTS coefficients (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	term 					integer references clutterterms(id) on delete cascade,
	cluttertype 	integer references cluttertype(id),
	coefficient 	real
);
CREATE OR REPLACE VIEW coefficients_view AS select * from coefficients;

-- File Sets
CREATE SEQUENCE filesets_id_seq;
CREATE TABLE IF NOT EXISTS filesets (
	id 						smallint primary key unique not null default nextval('filesets_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	SetName 			varchar(50),
	description 	text,
	filetype 			varchar(20),
	classgroup 		integer references classificationgroup(id),
	resolution 		real,
	date 					date,
	use 					boolean,
	derivedbinary boolean,
	origin 				smallint references filesets(id),
	fileformat 		varchar(10),
	projection 		varchar(10),
	proj4string 	varchar(100)
);
CREATE OR REPLACE VIEW filesets_view AS select * from filesets;

-- Source files
CREATE TABLE IF NOT EXISTS sourcefiles (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	filesetkey 		smallint references filesets(id),
	filename 			text,
	location 			text,
	areasquare 		box,
	centmer real
);
CREATE OR REPLACE VIEW sourcefiles_view AS select * from sourcefiles;


-- Data Source
CREATE SEQUENCE measdatasource_id_seq;
CREATE TABLE IF NOT EXISTS measdatasource (
	id 						smallint primary key unique not null default nextval('measdatasource_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	date 					timestamp without time zone,
	name 					varchar(20),
	description 	text,
	mobile 				integer references mobile(id)
);

-- Position Source
CREATE SEQUENCE positionsource_id_seq;
CREATE TABLE IF NOT EXISTS positionsource (
	id 						smallint primary key unique not null default nextval('positionsource_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	name 					varchar(20),
	description 	text
);

-- Measurement Type
CREATE SEQUENCE meastype_id_seq;
CREATE TABLE IF NOT EXISTS meastype (
	id 						smallint primary key unique not null default nextval('meastype_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	name 					varchar(20),
	description 	text
);

-- TestPoint
CREATE TABLE IF NOT EXISTS testpoint (
	id 							bigserial primary key unique not null,
	timeofmeas 			timestamp without time zone,
	location 				geography(POINT,4326),
	originaltp 			bigint references testpoint(id),
	measdatasource	smallint references measdatasource(id),
	positionsource 	smallint references positionsource(id),
	meastype 				smallint references meastype(id),
	height 					real
);

-- GSM Auxiliary Test Point info
CREATE TABLE IF NOT EXISTS testpointauxGSM (
	id 				bigserial primary key unique not null,
	tp 				bigint references testpoint(id),
	servci 		integer references cell(id) on delete cascade,
	TA 				smallint,
	PropDelay	smallint,
	BStxpower smallint,
	MStxpower smallint,
	BSrxpower smallint,
	MSrxpower smallint,
	BSrxQual 	smallint,
	MSrxQual 	smallint
);

-- UTRAN Auxiliary Test Point info
CREATE TABLE IF NOT EXISTS testpointauxUTRAN (
	id 				bigserial primary key unique not null,
	tp 				bigint references testpoint(id),
	servci 		integer references cell(id) on delete cascade,
	RxTxDiff 	int,
	RxTxDiff2	int
);

CREATE OR REPLACE VIEW tplist AS (select tp, servci, RxTxDiff as ta
						from testpointauxUTRAN
						where RxTxDiff is not null
						union
						select tp, servci, RxTxDiff2 as ta
						from testpointauxUTRAN
						where RxTxDiff2 is not null
						union
						select tp, servci, ta
						from testpointauxGSM);


-- PositionEstimate
CREATE TABLE IF NOT EXISTS PositionEstimate (
	id 				bigserial primary key unique not null,
	tp 				integer references testpoint(id) on delete cascade,
	azimuth 	real,
	distance	real,
	error 		real
);


-- Measurement
CREATE TABLE measurement (
	id 							bigserial primary key unique not null,
	ci 							integer references cell(id) on delete cascade,
	tp 							integer references testpoint(id) on delete cascade,
	frequency				real,
	azimuth 				real,
	tilt 						real,
	distance				real,
	pathloss				real,
	measvalue				real,
	predictvalue 		real,
	simulatedvalue	real
);


-- List of cells with pilot frequencies and codes (i.e. BCCH and BSIC for GSM and ARFCN and SCN for UMTS)
CREATE TABLE Celllist (
	id 						bigserial primary key unique not null,
	lastmodified	timestamp without time zone,
 	ci 						integer references cell(id) on delete cascade,
	Carrier				int,
	Code 					int
);


-- List of saved artificial neural nets for antenna patterns
CREATE TABLE AntNeuralNet (
	id 						serial not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
 	cellid				integer references cell(id) on delete cascade,
	filename			text
);

-- Neural Network Describtion
CREATE SEQUENCE anntype_id_seq;
CREATE TABLE anntype (
	id 						smallint primary key unique not null default nextval('anntype_id_seq'),
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	name 					varchar(20),
	description		text
);

-- List of saved artificial neural nets
CREATE TABLE NeuralNet (
	id 						serial not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	type 					integer references anntype(id) on delete cascade,
	siteid				integer references site(id) on delete cascade,
	maxDist				real,
	NumInputs 		integer,
	NumOutputs		integer,
	filename			text
);

-- List of cells related to the inputs of a particular neural net
CREATE TABLE ANNInputlist (
	id			bigserial primary key unique not null,
	siteid	integer references site(id) on delete cascade,
	annid		integer,
	index		integer,
	cellid	integer references cell(id) on delete cascade
);

-- Cable Type
CREATE TABLE cable_type (
	id										serial primary key unique not null,
	lastmodified 					timestamp without time zone,
	cabletype 						varchar(15),
	cost_per_metre 				numeric(12,2),
	signal_loss_per_metre	numeric(12,2)
);
CREATE OR REPLACE VIEW cable_type_view AS select * from cable_type;

-- Cable
CREATE TABLE cable (
	id								serial primary key unique not null,
	lastmodified			timestamp without time zone,
	machineid 				smallint references machine(id),
	rikey							integer references radioinstallation(id) on delete cascade,
	cablekey					integer references cable_type(id),
	installationdate	date,
	txlength					integer,
	rxlength					integer
);
CREATE OR REPLACE VIEW cable_view AS select * from cable;

-- Combiner/Splitter Type
CREATE TABLE combiner_splitter_type (
	id 											serial primary key unique not null,
	lastmodified 						timestamp without time zone,
	machineid 							smallint references machine(id),
  description							varchar(15),
	combiner_splitter_type	varchar(15),
	cost										numeric(12,2),
  losses 									numeric(12,2)
);
CREATE OR REPLACE VIEW combiner_splitter_type_view AS select * from combiner_splitter_type;

-- combiner_splitter
CREATE TABLE combiner_splitter (
	id 										serial primary key unique not null,
	lastmodified 					timestamp without time zone,
	machineid 						smallint references machine(id),
	rikey 								integer references radioinstallation(id) on delete cascade,
	combiner_splitter_key	integer references combiner_splitter_type(id),
	installationdate 			date
);
CREATE OR REPLACE VIEW combiner_splitter_view As select * from combiner_splitter;

-- Receiver Capabilities
CREATE TABLE receiver_capabilities (
	id 						serial primary key unique not null,
	lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
	data_rate 		integer,
	txpower 			integer,
	rxsensitivity integer
);
CREATE OR REPLACE VIEW receiver_capabilities_view AS select * from receiver_capabilities;
        
-- Height Costs
CREATE TABLE height_costs (
	id 						serial primary key unique not null,
  lastmodified	timestamp without time zone,
	machineid 		smallint references machine(id),
  height 				int,
	cost 					numeric(12,2)
);
CREATE OR REPLACE VIEW height_costs_view AS select * from height_costs;

-- The configs.
CREATE TABLE qrap_config (
	id 						serial primary key unique not null, 
	lastmodified	timestamp, 
	type 					varchar(20), 
	username 			varchar(100), 
	name 					varchar(100), 
	value 				text
);
CREATE TABLE qrap_undo (
	id 				serial primary key unique not null, 
	username	varchar(100), 
	cmd 			text
);
CREATE TABLE qrap_regions (
	id 						serial primary key unique not null, 
	lastmodified	timestamp, 
	name 					varchar(100), 
	parent 				integer references qrap_regions(id), 
	description 	text, 
	region 				polygon
);
CREATE TABLE qrap_users (
	id 				serial primary key unique not null, 
	username 	varchar(100), 
	password 	varchar(40), 
	groupname	varchar(100), 
	fullnames varchar(300), 
	idno 			varchar(30), 
	email 		varchar(200)
);
CREATE TABLE qrap_groups (id serial primary key unique not null, groupname varchar(100), rulename varchar(100), tablename varchar(100), cmd varchar(20), limiter text, docmd text);
