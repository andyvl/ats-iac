CREATE USER atsowner WITH PASSWORD 'atsowner';
CREATE DATABASE ats_intralot;
GRANT ALL PRIVILEGES ON DATABASE ats_intralot TO atsowner;

-- Schema --
CREATE TABLE public.account_bonus_workups (
	id int8 NOT NULL DEFAULT nextval('account_bonus_workups_id_seq'::regclass),
	created timestamptz NOT NULL DEFAULT now(),
	acco_id int8 NULL,
	bonus_campaign_id int8 NULL,
	overrides varchar(255) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id),
	FOREIGN KEY (bonus_campaign_id) REFERENCES bonus_campaigns(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.account_bonuses (
	id int8 NOT NULL DEFAULT nextval('account_bonuses_id_seq'::regclass),
	created timestamptz NOT NULL DEFAULT now(),
	state varchar(20) NOT NULL,
	acco_id int8 NULL,
	bonus_campaign_id int8 NULL,
	overrides varchar(255) NULL,
	modified timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id),
	FOREIGN KEY (bonus_campaign_id) REFERENCES bonus_campaigns(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX account_bonuses_acco_id_state_idx ON account_bonuses USING btree (acco_id, state) ;
CREATE INDEX account_bonuses_bonus_campaign_id_idx ON account_bonuses USING btree (bonus_campaign_id) ;
CREATE INDEX account_bonuses_state_idx ON account_bonuses USING btree (state) WHERE ((state)::text = 'PARTIAL'::text) ;

CREATE TABLE public.account_bonuses_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	created timestamptz NULL,
	state varchar(20) NULL,
	acco_id int8 NULL,
	bonus_campaign_id int8 NULL,
	overrides varchar(255) NULL,
	modified timestamptz NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.account_details (
	id int4 NOT NULL DEFAULT nextval('account_details_id_seq'::regclass),
	acco_id int8 NOT NULL,
	email_valid numeric(1) NULL DEFAULT 0,
	phone_valid numeric(1) NULL DEFAULT 0,
	mobile_valid numeric(1) NULL DEFAULT 0,
	registration_status varchar(32) NULL,
	email_confirmation_code varchar(100) NULL,
	fraud_color varchar(16) NULL,
	scoring text NULL,
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int8 NULL DEFAULT 0,
	newsletter_subscribed numeric(1) NULL DEFAULT 0,
	limitations text NULL,
	conditions text NULL,
	registration_ip varchar(30) NULL,
	scoring_modified timestamptz NULL,
	segment_license_code varchar(30) NULL,
	lpid int4 NULL,
	referrer varchar(20) NULL,
	extra_details json NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX account_details_acco_id_idx ON account_details USING btree (acco_id) ;

CREATE TABLE public.account_documents (
	id int4 NOT NULL DEFAULT nextval('account_documents_id_seq'::regclass),
	acco_id int8 NOT NULL,
	proof_type varchar(32) NULL,
	proof varchar(32) NULL,
	uploaded_on timestamptz NULL,
	expires_on timestamptz NULL,
	approval_status varchar(32) NULL,
	rejection_reason text NULL,
	user_comments text NULL,
	doc_link varchar(255) NULL,
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int8 NULL DEFAULT 0,
	file_name varchar(100) NULL,
	content_type varchar(64) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX account_documents_acco_id_idx ON account_documents USING btree (acco_id) ;

CREATE TABLE public.account_documents_data (
	id int8 NOT NULL DEFAULT nextval('account_documents_data_id_seq'::regclass),
	acco_id int8 NULL,
	raw_data bytea NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.account_history (
	modified timestamptz NOT NULL,
	modifier_acc_id int8 NULL,
	modified_acc_id int8 NULL,
	"data" json NOT NULL,
	id int8 NOT NULL DEFAULT nextval('account_history_id_seq'::regclass),
	pinned bool NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX account_history_modified_acc_id_idx ON account_history USING btree (modified_acc_id) ;
CREATE INDEX account_history_modifier_acc_id_idx ON account_history USING btree (modifier_acc_id) ;

CREATE TABLE public.account_messages (
	message_id int8 NULL,
	acco_id int8 NULL,
	viewed timestamp NULL,
	FOREIGN KEY (acco_id) REFERENCES accounts(id),
	FOREIGN KEY (message_id) REFERENCES messages(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.account_preferences (
	id int8 NOT NULL DEFAULT nextval('account_preferences_id_seq'::regclass),
	acc_id int8 NOT NULL DEFAULT 0::bigint,
	category varchar(50) NOT NULL,
	name varchar(100) NOT NULL,
	value varchar(15000) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (acc_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.account_preferences_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	acc_id int8 NULL,
	category varchar(50) NULL,
	name varchar(100) NULL,
	value varchar(15000) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX account_preferences_history_id_idx ON account_preferences_history USING btree (id) ;

CREATE TABLE public.account_segments (
	accounts_id int8 NOT NULL,
	customer_segments_id int8 NOT NULL,
	created timestamptz NOT NULL DEFAULT now(),
	overrides varchar(255) NULL,
	PRIMARY KEY (accounts_id, customer_segments_id),
	FOREIGN KEY (accounts_id) REFERENCES accounts(id),
	FOREIGN KEY (accounts_id) REFERENCES accounts(id),
	FOREIGN KEY (customer_segments_id) REFERENCES customer_segments(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.accounts (
	id int8 NOT NULL DEFAULT nextval('accounts_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	user_id int8 NULL,
	creation_date timestamptz NOT NULL DEFAULT now(),
	balance numeric NOT NULL DEFAULT 0.000000,
	currency_code varchar(3) NOT NULL DEFAULT 'GBP'::character varying,
	status varchar(10) NOT NULL DEFAULT 'ACTIVE'::character varying,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	country_code varchar(5) NULL,
	amount_mult numeric(5,2) NULL DEFAULT 100.00,
	chan_id int8 NULL,
	inplay_delay_cat varchar(80) NULL,
	colour_cat varchar(30) NULL,
	bet_limit_curr varchar(3) NULL,
	inplay_stake_coef numeric(5,2) NULL,
	pre_match_stake_coef numeric(5,2) NULL,
	bet_limit int8 NULL,
	min_stake numeric(5,2) NULL,
	name varchar(60) NULL,
	live_bet_limit int8 NULL,
	watchlist numeric(1) NOT NULL DEFAULT 0::numeric,
	exclude_alert numeric(1) NOT NULL DEFAULT 0::numeric,
	town varchar(50) NULL,
	country varchar(50) NULL,
	price_adjustment varchar(50) NULL,
	punter_limits text NULL,
	acc_id int8 NULL,
	agent_position numeric(5,2) NULL,
	kyc_info text NULL,
	kyc_needed numeric(1) NOT NULL DEFAULT 1,
	self_limits text NULL,
	username varchar(60) NULL,
	password varchar(60) NULL,
	last_login_time timestamptz NULL DEFAULT now(),
	credentials text NULL,
	contact_details text NULL,
	password_challenge text NULL,
	email varchar(100) NULL,
	active_wallet_type_id int8 NULL DEFAULT 1::numeric,
	active_fund_type_id int8 NULL DEFAULT 1::numeric,
	exclude_cashout numeric(1) NULL DEFAULT 0::numeric,
	"path" varchar(255) NULL,
	orun_path varchar(255) NULL,
	suspended_by varchar(64) NULL,
	vip numeric(1) NULL DEFAULT 0,
	test numeric(1) NULL DEFAULT 0,
	preferred_language varchar(5) NULL,
	has_logged_in bool NULL DEFAULT false,
	login_attempts int2 NULL DEFAULT 0,
	terms_and_conditions varchar NULL,
	vip_group int2 NULL,
	profile text NULL,
	product_visibility text NULL,
	has_churn bool NULL,
	brand_id int2 NULL,
	casino_vip numeric(1) NULL,
	retailer_id int8 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (brand_id) REFERENCES brands(id),
	FOREIGN KEY (chan_id) REFERENCES channels(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (retailer_id) REFERENCES retailers(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_account_11" ON accounts USING btree (chan_id) ;
CREATE UNIQUE INDEX accounts_lower_idx ON accounts USING btree (lower((email)::text)) ;
CREATE INDEX accounts_lower_name_idx ON accounts USING btree (lower((name)::text) varchar_pattern_ops) ;
CREATE UNIQUE INDEX accounts_lower_username_idx ON accounts USING btree (lower((username)::text)) ;
CREATE INDEX accounts_punterlimits_idx ON accounts USING btree (punter_limits varchar_pattern_ops) ;
CREATE UNIQUE INDEX accounts_unique_ref1_idx ON accounts USING btree (ref1) ;
CREATE INDEX accounts_uppername_idx ON accounts USING btree (upper((name)::text) varchar_pattern_ops) ;
CREATE INDEX accounts_watchlist_idx ON accounts USING btree (watchlist) WHERE (watchlist = (1)::numeric) ;

CREATE TABLE public.accounts_history (
	clock_timestamp timestamptz NULL,
	application_name varchar(30) NULL,
	id int8 NULL,
	deleted numeric(1) NULL,
	oca int8 NULL,
	modified timestamptz NULL,
	user_id int8 NULL,
	creation_date timestamptz NULL,
	balance numeric NULL,
	currency_code varchar(3) NULL,
	status varchar(10) NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	country_code varchar(5) NULL,
	amount_mult numeric(5,2) NULL,
	chan_id int8 NULL,
	inplay_delay_cat varchar(80) NULL,
	colour_cat varchar(30) NULL,
	bet_limit_curr varchar(3) NULL,
	inplay_stake_coef numeric(5,2) NULL,
	pre_match_stake_coef numeric(5,2) NULL,
	bet_limit int8 NULL,
	min_stake numeric(5,2) NULL,
	name varchar(60) NULL,
	live_bet_limit int8 NULL,
	watchlist numeric(1) NULL,
	exclude_alert numeric(1) NULL,
	town varchar(50) NULL,
	country varchar(50) NULL,
	price_adjustment varchar(50) NULL,
	punter_limits text NULL,
	acc_id int8 NULL,
	agent_position numeric(5,2) NULL,
	kyc_info text NULL,
	kyc_needed numeric(1) NULL,
	self_limits text NULL,
	username varchar(60) NULL,
	password varchar(60) NULL,
	last_login_time timestamptz NULL,
	credentials text NULL,
	contact_details text NULL,
	password_challenge text NULL,
	email varchar(100) NULL,
	active_wallet_type_id int8 NULL,
	active_fund_type_id int8 NULL,
	exclude_cashout numeric(1) NULL,
	"path" varchar(255) NULL,
	orun_path varchar(255) NULL,
	suspended_by varchar(64) NULL,
	vip numeric(1) NULL,
	test numeric(1) NULL,
	preferred_language varchar(5) NULL,
	has_logged_in bool NULL,
	login_attempts int2 NULL,
	terms_and_conditions varchar NULL,
	vip_group int2 NULL,
	profile text NULL,
	product_visibility text NULL,
	has_churn bool NULL,
	brand_id int2 NULL,
	casino_vip numeric(1) NULL,
	retailer_account_id int8 NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.accounts_pending (
	id int8 NOT NULL DEFAULT nextval('accounts_pending_id_seq'::regclass),
	acco_id int8 NOT NULL,
	"type" varchar(20) NOT NULL,
	retries int2 NOT NULL DEFAULT 0,
	deleted numeric(1) NOT NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	nra_active bool NOT NULL DEFAULT false,
	scg_active bool NOT NULL DEFAULT false,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX accounts_pending_acco_id_idx ON accounts_pending USING btree (acco_id) ;

CREATE TABLE public.alerts (
	id int8 NOT NULL DEFAULT nextval('alerts_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	alert_type varchar(10) NOT NULL,
	threshold varchar(15) NOT NULL,
	user_id int8 NOT NULL DEFAULT 0::bigint,
	inst_id int8 NOT NULL,
	dafi_id int8 NOT NULL DEFAULT 0::bigint,
	active_after_logoff numeric(1) NOT NULL DEFAULT 0::numeric,
	PRIMARY KEY (id),
	FOREIGN KEY (dafi_id) REFERENCES temp.data_fields(id) MATCH FULL,
	FOREIGN KEY (inst_id) REFERENCES instruments(id) MATCH FULL,
	FOREIGN KEY (user_id) REFERENCES users(id) MATCH FULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX alerts_inst_id_fkey_idx ON alerts USING btree (inst_id) ;
CREATE INDEX alerts_user_id_fkey_idx ON alerts USING btree (user_id) ;

CREATE TABLE public.algo_settings (
	id int8 NOT NULL DEFAULT nextval('algo_settings_id_seq'::regclass),
	settings varchar(200) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.algomgr_item_headers (
	match_id int8 NOT NULL,
	header_timestamp timestamptz NOT NULL DEFAULT now(),
	header json NULL,
	FOREIGN KEY (match_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX algomgr_item_headers_match_id_idx ON algomgr_item_headers USING btree (match_id) ;

CREATE TABLE public.algomgr_item_recordings (
	match_id int8 NOT NULL,
	action_timestamp timestamptz NOT NULL DEFAULT now(),
	item_type varchar(50) NOT NULL,
	item json NULL,
	FOREIGN KEY (match_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX algomgr_item_recordings_match_id_idx ON algomgr_item_recordings USING btree (match_id) ;

CREATE TABLE public.arbitrary_text (
	id int4 NOT NULL DEFAULT nextval('arbitrary_text_id_seq'::regclass),
	default_text text NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id),
	UNIQUE (default_text)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.asian_feed_settings_templates (
	id int8 NOT NULL DEFAULT nextval('asian_feed_settings_templates_id_seq'::regclass),
	name varchar(150) NOT NULL,
	primary_bookies varchar(350) NULL,
	secondary_bookies varchar(350) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	node_id int8 NOT NULL DEFAULT 166661,
	PRIMARY KEY (id),
	UNIQUE (name),
	FOREIGN KEY (node_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.asian_lines_movements (
	id int8 NOT NULL DEFAULT nextval('asian_lines_movements_id_seq'::regclass),
	event_id int8 NOT NULL,
	"date" timestamptz NOT NULL,
	parentname varchar(60) NOT NULL,
	nodename varchar(60) NOT NULL,
	market varchar(150) NOT NULL,
	change_type varchar(5) NOT NULL,
	selection varchar(250) NOT NULL,
	prev_value varchar(20) NOT NULL,
	curr_value varchar(20) NOT NULL,
	keyvariable varchar(30) NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.audits (
	id int8 NOT NULL DEFAULT nextval('audits_id_seq'::regclass),
	"path" varchar(100) NULL,
	etime timestamptz NULL,
	ename varchar(150) NULL,
	mname varchar(150) NULL,
	iname varchar(250) NULL,
	details varchar(1000) NULL,
	"action" varchar(50) NOT NULL,
	userid int4 NOT NULL DEFAULT 0,
	account_ref varchar(32) NULL,
	oval varchar(500) NULL,
	nval varchar(500) NULL,
	inst_id int8 NULL,
	"timestamp" timestamptz NOT NULL DEFAULT now(),
	country_code varchar(5) NULL,
	oper_id varchar(50) NULL,
	state_id varchar(50) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX audits_path_action_idx ON audits USING btree (path varchar_pattern_ops, action varchar_pattern_ops) ;

CREATE TABLE public.bank_codes (
	id int4 NOT NULL DEFAULT nextval('bank_codes_id_seq'::regclass),
	bank_name varchar(100) NULL,
	ibank_routing_code varchar(20) NULL,
	nibbs_code varchar(20) NULL,
	nibbs_code2 varchar(20) NULL,
	bank_code varchar(50) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX bank_codes_bank_code_idx ON bank_codes USING btree (bank_code) ;

CREATE TABLE public.betsync_user_profiles (
	user_id int8 NOT NULL,
	userprofile json NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX betsync_user_profiles_user_id_idx ON betsync_user_profiles USING btree (user_id) ;

CREATE TABLE public.betting_chart_data (
	id int8 NOT NULL DEFAULT nextval('betting_chart_data_id_seq'::regclass),
	name varchar(30) NOT NULL,
	"type" varchar(100) NOT NULL,
	"data" varchar(15000) NOT NULL,
	format varchar(20) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.betting_instruments (
	id int8 NOT NULL DEFAULT nextval('betting_instruments_id_seq'::regclass),
	betmark_id int8 NULL,
	inst_id int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	comp_id int8 NULL,
	FOREIGN KEY (betmark_id) REFERENCES betting_markets(id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (inst_id) REFERENCES instruments(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (inst_id) REFERENCES instruments(id),
	FOREIGN KEY (betmark_id) REFERENCES betting_markets(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX betting_instruments_betmark_id_ix ON betting_instruments USING btree (betmark_id) ;
CREATE UNIQUE INDEX betting_instruments_pid ON betting_instruments USING btree (id) ;
CREATE UNIQUE INDEX betting_instruments_unique_inst_idx ON betting_instruments USING btree (inst_id) ;

CREATE TABLE public.betting_markets (
	id int8 NOT NULL DEFAULT nextval('betting_markets_id_seq'::regclass),
	betnode_id int8 NULL,
	mark_id int8 NULL,
	gp_avail numeric(1) NOT NULL DEFAULT 0::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	ew_available numeric(1) NULL DEFAULT 0::numeric,
	ew_places int8 NULL,
	ew_deduction varchar(10) NULL,
	dest_avail int8 NULL,
	FOREIGN KEY (betnode_id) REFERENCES betting_nodes(id),
	FOREIGN KEY (mark_id) REFERENCES markets(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (mark_id) REFERENCES markets(id),
	FOREIGN KEY (betnode_id) REFERENCES betting_nodes(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX betting_markets_betnode_id ON betting_markets USING btree (betnode_id) ;
CREATE UNIQUE INDEX betting_markets_id ON betting_markets USING btree (id) ;
CREATE INDEX betting_markets_mark_id ON betting_markets USING btree (mark_id) ;

CREATE TABLE public.betting_node_participants (
	id int8 NOT NULL DEFAULT nextval('betting_node_participants_id_seq'::regclass),
	beno_id int8 NOT NULL,
	comp_id int8 NOT NULL,
	comp_parent_id int8 NULL,
	"position" varchar(10) NULL DEFAULT NULL::character varying,
	"number" int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (beno_id) REFERENCES betting_nodes(id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id),
	FOREIGN KEY (comp_parent_id) REFERENCES competitors(id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (beno_id) REFERENCES betting_nodes(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX betting_node_participants_beno_id_ix ON betting_node_participants USING btree (beno_id) ;
CREATE INDEX betting_node_participants_comp_id_ix ON betting_node_participants USING btree (comp_id) ;

CREATE TABLE public.betting_nodes (
	id int8 NOT NULL DEFAULT nextval('betting_nodes_id_seq'::regclass),
	node_id int8 NULL,
	started numeric(1) NULL DEFAULT 0::numeric,
	visible numeric(1) NOT NULL DEFAULT 1::numeric,
	state varchar(15) NOT NULL DEFAULT 'ACTIVE'::character varying,
	man_state varchar(15) NULL DEFAULT NULL::character varying,
	category varchar(30) NULL DEFAULT NULL::character varying,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	bet_state varchar(15) NULL DEFAULT NULL::character varying,
	dest_avail int8 NULL,
	chan_avail int8 NULL,
	chan_create_fail int4 NULL,
	stoc_id int8 NULL,
	venue varchar(100) NULL,
	bir numeric(2) NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (node_id) REFERENCES nodes(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (node_id) REFERENCES nodes(id),
	FOREIGN KEY (stoc_id) REFERENCES stage_of_competitions(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX beno_n1 ON betting_nodes USING btree (node_id) ;

CREATE TABLE public.betting_repetition_rule (
	id int8 NOT NULL DEFAULT nextval('betting_repetition_rule_id_seq'::regclass),
	similar_bets int8 NOT NULL,
	customer_type varchar(20) NOT NULL,
	window_type text NOT NULL,
	min_stake int8 NOT NULL,
	global_rule bool NOT NULL DEFAULT false,
	description varchar(255) NULL,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	combinations varchar(4000) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.bonus_campaign_templates (
	id int8 NOT NULL DEFAULT nextval('bonus_campaign_templates_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.bonus_campaigns (
	id int8 NOT NULL DEFAULT nextval('bonus_campaigns_id_seq'::regclass),
	"data" json NOT NULL,
	modified timestamptz NULL DEFAULT clock_timestamp(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.bonus_campaigns_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	"data" json NULL,
	modified timestamptz NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX bonus_campaigns_history_modified_idx ON bonus_campaigns_history USING btree (modified DESC) ;

CREATE TABLE public.booked_events (
	booked_events_id int4 NOT NULL DEFAULT nextval('booked_events_booked_events_id_seq'::regclass),
	node_id int8 NULL,
	user_id int8 NULL,
	sport_code varchar(45) NULL,
	created timestamptz NULL DEFAULT now(),
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int4 NULL DEFAULT 0,
	days_ahead int4 NULL,
	max_events int4 NULL,
	PRIMARY KEY (booked_events_id),
	FOREIGN KEY (node_id) REFERENCES nodes(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX idx_booked_events_node_id_user_id ON booked_events USING btree (node_id, user_id) ;

CREATE TABLE public.brands (
	id int2 NOT NULL DEFAULT nextval('brands_id_seq'::regclass),
	name varchar(50) NOT NULL,
	code varchar(20) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0,
	created timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.campaign_accounts (
	accounts_id int8 NOT NULL,
	campaign_id int8 NOT NULL,
	created timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (accounts_id, campaign_id),
	FOREIGN KEY (accounts_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.channel_mappings (
	parent_channel_id int8 NOT NULL,
	child_channel_id int8 NOT NULL,
	FOREIGN KEY (child_channel_id) REFERENCES channels(id),
	FOREIGN KEY (parent_channel_id) REFERENCES channels(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.channels (
	id int8 NOT NULL DEFAULT nextval('channels_id_seq'::regclass),
	name varchar(50) NOT NULL,
	chan_type varchar(50) NULL,
	mask int8 NOT NULL DEFAULT 0::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	code varchar(50) NOT NULL DEFAULT ''::character varying,
	price_format varchar(10) NULL,
	master numeric(1) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX channels_code ON channels USING btree (code) ;
CREATE UNIQUE INDEX channels_name ON channels USING btree (name) ;

CREATE TABLE public.cms_market_groups (
	id int4 NOT NULL DEFAULT nextval('cms_market_groups_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.competition_priority_config (
	id int8 NOT NULL DEFAULT nextval('competition_priority_config_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.competitor_mappings (
	id int8 NOT NULL,
	parent_id int8 NOT NULL,
	"number" int8 NULL,
	PRIMARY KEY (id, parent_id),
	FOREIGN KEY (parent_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.competitors (
	id int8 NOT NULL DEFAULT nextval('competitors_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	name varchar(150) NOT NULL,
	active numeric(1) NOT NULL,
	syst_id int8 NULL,
	sys_ref varchar(70) NULL DEFAULT NULL::character varying,
	created timestamptz NULL DEFAULT now(),
	chan_avail int8 NULL,
	short_name varchar(50) NULL,
	very_short_name varchar(50) NULL,
	chan_create_fail int4 NULL,
	"rank" int8 NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX competitors_sys_ref_syst_id_idx ON competitors USING btree (sys_ref, syst_id) ;

CREATE TABLE public.competitors_external_data (
	id int8 NOT NULL DEFAULT nextval('competitors_external_data_id_seq'::regclass),
	name varchar(255) NOT NULL,
	ext_id varchar(255) NOT NULL,
	syst_id int8 NOT NULL,
	entity_type varchar(30) NOT NULL,
	sport_code varchar(10) NOT NULL,
	other_attributes varchar(255) NULL DEFAULT NULL::character varying,
	comp_id int8 NULL,
	created timestamptz NULL DEFAULT now(),
	sys_ref text NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX competitors_external_data_entitytype_extid_idx ON competitors_external_data USING btree (entity_type varchar_pattern_ops, ext_id varchar_pattern_ops) ;

CREATE TABLE public.countries (
	id int2 NOT NULL DEFAULT nextval('countries_id_seq'::regclass),
	name varchar(50) NOT NULL,
	code2 varchar(2) NOT NULL,
	code3 varchar(3) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX unique_country_code3_idx ON countries USING btree (lower((code3)::text)) ;
CREATE UNIQUE INDEX unique_country_name_idx ON countries USING btree (lower((name)::text)) ;

CREATE TABLE public.country_currencies (
	country_id int2 NOT NULL,
	currency_id int2 NOT NULL,
	PRIMARY KEY (country_id, currency_id),
	FOREIGN KEY (country_id) REFERENCES countries(id),
	FOREIGN KEY (currency_id) REFERENCES currencies(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.coupon_codes_reservations (
	id int8 NOT NULL DEFAULT nextval('coupon_codes_reservations_id_seq'::regclass),
	node_id int8 NOT NULL,
	reserved_from timestamptz NOT NULL,
	reserved_to timestamptz NULL,
	mode varchar(10) NOT NULL,
	code varchar(10) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.coupon_codes_settings (
	id int8 NOT NULL DEFAULT nextval('coupon_codes_settings_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.coupon_nodes (
	coup_id int8 NOT NULL DEFAULT 0::bigint,
	node_id int8 NOT NULL DEFAULT 0::bigint,
	PRIMARY KEY (coup_id, node_id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "I_coupon_nodes_1" ON coupon_nodes USING btree (coup_id) ;
CREATE INDEX "I_coupon_nodes_2" ON coupon_nodes USING btree (node_id) ;

CREATE TABLE public.coupon_selection_codes (
	id int8 NOT NULL DEFAULT nextval('coupon_selection_codes_id_seq'::regclass),
	name varchar(50) NOT NULL,
	market_type varchar(100) NOT NULL,
	handicap varchar(10) NULL,
	selection_type varchar(150) NOT NULL,
	code varchar(10) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.coupon_selection_codes_settings (
	id int8 NOT NULL DEFAULT nextval('coupon_selection_codes_settings_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.coupons (
	id int8 NOT NULL DEFAULT nextval('coupons_id_seq'::regclass),
	name varchar(100) NOT NULL,
	node_id int8 NOT NULL,
	mrkt_type varchar(50) NOT NULL,
	display numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_coupons_11" ON coupons USING btree (node_id) ;

CREATE TABLE public.currencies (
	id int8 NOT NULL DEFAULT nextval('currencies_id_seq'::regclass),
	ext_id varchar(4) NULL,
	name varchar(30) NOT NULL,
	code varchar(3) NOT NULL,
	symbol varchar(8) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	principal numeric(1) NOT NULL DEFAULT 0::numeric,
	creation_date timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX currencies_principal_idx ON currencies USING btree (principal) WHERE (principal = (1)::numeric) ;
CREATE UNIQUE INDEX unique_currency_code_idx ON currencies USING btree (lower((code)::text)) ;

CREATE TABLE public.currency_settings (
	id int4 NOT NULL DEFAULT nextval('currency_settings_id_seq'::regclass),
	"data" json NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.customer_segments (
	id int4 NOT NULL DEFAULT nextval('customer_segments_id_seq'::regclass),
	"data" json NOT NULL,
	name varchar(60) NULL,
	"type" varchar(20) NULL,
	bonus_segment int2 NULL,
	limits_segment int2 NULL,
	created timestamptz NULL DEFAULT now(),
	default_limits_segment numeric(1) NOT NULL DEFAULT 0::numeric,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.customer_segments_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int4 NULL,
	"data" json NULL,
	name varchar(60) NULL,
	"type" varchar(20) NULL,
	bonus_segment int2 NULL,
	limits_segment int2 NULL,
	created timestamptz NULL,
	default_limits_segment numeric(1) NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX customer_segments_history_id_idx ON customer_segments_history USING btree (id) ;

CREATE TABLE public.dbchanges (
	dbchange_id int8 NOT NULL,
	ats_version varchar(10) NULL,
	md5 varchar(32) NULL,
	filename varchar(200) NULL,
	applied timestamptz NULL DEFAULT now(),
	backup_code text NULL,
	PRIMARY KEY (dbchange_id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.dbrolechanges (
	id int4 NULL,
	created timestamptz NULL DEFAULT now(),
	description varchar(150) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.deductions (
	id int4 NOT NULL DEFAULT nextval('deductions_id_seq'::regclass),
	"type" varchar(50) NOT NULL,
	mark_id int8 NOT NULL,
	amount int4 NOT NULL,
	from_time timestamptz NULL DEFAULT now(),
	to_time timestamptz NULL DEFAULT now(),
	confirmed numeric(1) NOT NULL DEFAULT 0,
	created timestamptz NULL DEFAULT now(),
	deleted numeric(1) NOT NULL DEFAULT 0,
	channel varchar(50) NULL,
	comments varchar(300) NULL,
	manual numeric(1) NOT NULL DEFAULT 0,
	inst_id int8 NULL,
	FOREIGN KEY (inst_id) REFERENCES instruments(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (mark_id) REFERENCES markets(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.display_groups (
	id int8 NOT NULL DEFAULT nextval('display_groups_id_seq'::regclass),
	name varchar(255) NOT NULL,
	market_types varchar(1024) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	maar_id int8 NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX display_groups_maar_id_idx ON display_groups USING btree (maar_id) ;

CREATE TABLE public.display_market_groups (
	id int8 NOT NULL DEFAULT nextval('display_market_groups_id_seq'::regclass),
	name varchar(50) NOT NULL,
	channel varchar(50) NULL,
	display_order numeric(4) NULL,
	market_types varchar(5000) NULL,
	maar_id int8 NULL,
	headline varchar(50) NULL,
	segment varchar(50) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id),
	FOREIGN KEY (maar_id) REFERENCES market_areas(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.dividends (
	id int4 NOT NULL DEFAULT nextval('dividends_id_seq'::regclass),
	"type" varchar(50) NOT NULL,
	mark_id int8 NOT NULL,
	instr1_id int8 NOT NULL,
	instr2_id int8 NULL,
	instr3_id int8 NULL,
	dividend numeric(12,4) NOT NULL,
	created timestamptz NULL DEFAULT now(),
	deleted numeric(1) NOT NULL DEFAULT 0,
	dividend_confirmed numeric(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.dogs (
	comp_id int8 NOT NULL,
	PRIMARY KEY (comp_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.entity_sys_refs (
	id int8 NOT NULL DEFAULT nextval('entity_sys_refs_id_seq'::regclass),
	entity_type varchar(30) NOT NULL,
	sys_ref varchar(30) NOT NULL,
	ats_id int8 NOT NULL,
	systems_id int8 NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	TRIGGER DEFERRABLE,
	TRIGGER DEFERRABLE
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX entity_sys_refs_deleted_entitytype_atsid_systemsid_idx ON entity_sys_refs USING btree (deleted, entity_type varchar_pattern_ops, ats_id, systems_id) WHERE ((deleted = (0)::numeric) AND ((entity_type)::text = 'BETRADAR_PLAYER'::text) AND (systems_id = 20)) ;
CREATE INDEX entity_sys_refs_sys_ref_entity_type_idx ON entity_sys_refs USING btree (sys_ref, entity_type) ;

CREATE TABLE public.event_history (
	node_id int8 NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	"data" json NOT NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX event_history_modified_node_id_idx ON event_history USING btree (modified DESC, node_id) ;

CREATE TABLE public.event_results (
	id int4 NOT NULL DEFAULT nextval('event_results_id_seq'::regclass),
	maar_id int8 NULL,
	match_time timestamptz NULL,
	name varchar(150) NOT NULL,
	summmary json NOT NULL,
	event_id int8 NULL,
	score_summary json NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX idx_event_results_name ON event_results USING btree (name) ;

CREATE TABLE public.event_templates (
	id int8 NOT NULL DEFAULT nextval('event_templates_id_seq'::regclass),
	name varchar(150) NOT NULL,
	node_id int8 NOT NULL,
	name_template varchar(150) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_event_templates_11" ON event_templates USING btree (node_id) ;

CREATE TABLE public.event_templates_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	name varchar(150) NULL,
	node_id int8 NULL,
	name_template varchar(150) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.event_tree_mappings (
	id int8 NOT NULL DEFAULT nextval('event_tree_mappings_id_seq'::regclass),
	name varchar(150) NOT NULL,
	syst_id int8 NOT NULL DEFAULT 0::bigint,
	pattern varchar(45) NULL,
	"path" varchar(100) NULL,
	name2 varchar(150) NOT NULL,
	syst2_id int8 NOT NULL DEFAULT 0::bigint,
	pattern2 varchar(45) NULL,
	path2 varchar(100) NULL,
	mapping_type varchar(20) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (syst2_id) REFERENCES systems(id) MATCH FULL,
	FOREIGN KEY (syst_id) REFERENCES systems(id) MATCH FULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX event_tree_mappings_mapping_type_idx ON event_tree_mappings USING btree (mapping_type) ;
CREATE INDEX event_tree_mappings_name_name2_mapping_type_idx ON event_tree_mappings USING btree (name, name2, mapping_type) ;
CREATE INDEX event_tree_mappings_syst2_id_fkey_idx ON event_tree_mappings USING btree (syst2_id) ;
CREATE INDEX event_tree_mappings_syst_id_fkey_idx ON event_tree_mappings USING btree (syst_id) ;

CREATE TABLE public.event_tree_settings (
	id int8 NOT NULL DEFAULT nextval('event_tree_settings_id_seq'::regclass),
	epath varchar(100) NOT NULL,
	setting_value varchar(15000) NOT NULL,
	setting_key varchar(100) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	UNIQUE (setting_key, epath)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX event_tree_settings_epath_idx ON event_tree_settings USING btree (epath varchar_pattern_ops) ;
CREATE INDEX event_tree_settings_epath_setting_key_idx ON event_tree_settings USING btree (epath, setting_key) ;

CREATE TABLE public.event_tree_settings_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	epath varchar(100) NULL,
	setting_value varchar NULL,
	setting_key varchar(100) NULL,
	active numeric(1) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX event_tree_settings_history_clock_timestamp_idx ON event_tree_settings_history USING btree (clock_timestamp) ;

CREATE TABLE public.feed_accounts (
	id int8 NOT NULL DEFAULT nextval('feed_accounts_id_seq'::regclass),
	feed_id int8 NOT NULL,
	account_name varchar(60) NOT NULL,
	username varchar(45) NOT NULL,
	password varchar(60) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	transactional numeric(1) NOT NULL DEFAULT 0::numeric,
	subscription_code varchar(25) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_feed_account_11" ON feed_accounts USING btree (feed_id) ;

CREATE TABLE public.feeds (
	id int8 NOT NULL DEFAULT nextval('feeds_id_seq'::regclass),
	name varchar(45) NOT NULL,
	syst_id int8 NOT NULL,
	state varchar(45) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	price_poll int8 NOT NULL DEFAULT 5000::bigint,
	event_refresh varchar(45) NOT NULL DEFAULT '0 0 22 * * ?'::character varying,
	priority int8 NOT NULL DEFAULT 1::bigint,
	event_types varchar(600) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (syst_id) REFERENCES systems(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.frontpage_links (
	id int4 NOT NULL DEFAULT nextval('frontpage_links_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX frontpage_links_expr_idx ON frontpage_links USING btree ((((data -> 'QuickLinks'::text) ->> 'region'::text))) ;

CREATE TABLE public.game_rules (
	id int8 NOT NULL DEFAULT nextval('game_rules_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.genbet_templates (
	sport_code varchar(10) NULL,
	ev_tmpl_id varchar(10) NULL,
	ev_tmpl_name varchar(100) NULL,
	mkt_tmpl_id varchar(10) NULL,
	mkt_tmpl_name varchar(100) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.highlight_categories (
	id int4 NOT NULL DEFAULT nextval('hlca_id_seq'::regclass),
	name varchar(100) NULL,
	default_market_types varchar(500) NULL,
	code varchar(50) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.highlighted_markets (
	id int4 NOT NULL DEFAULT nextval('hlmkt_id_seq'::regclass),
	hl_id int8 NULL,
	mark_id int8 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (hl_id) REFERENCES highlights(id),
	FOREIGN KEY (mark_id) REFERENCES markets(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.highlights (
	id int8 NOT NULL DEFAULT nextval('hl_id_seq'::regclass),
	node_id int8 NULL,
	hlca_id int4 NULL,
	active numeric(1) NULL,
	active_start timestamptz NULL,
	active_end timestamptz NULL,
	content text NULL,
	market_types varchar(500) NULL,
	img_location varchar(255) NULL,
	user_id int8 NULL,
	region varchar(5) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (hlca_id) REFERENCES highlight_categories(id),
	FOREIGN KEY (node_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.horses (
	comp_id int8 NOT NULL,
	PRIMARY KEY (comp_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.incidents (
	id int8 NOT NULL DEFAULT nextval('incidents_id_seq'::regclass),
	node_id int8 NOT NULL,
	incident_type varchar(40) NOT NULL,
	json text NOT NULL,
	incident_received timestamptz NULL DEFAULT now(),
	incident_id varchar(30) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX incident_id_idx ON incidents USING btree (incident_id) ;
CREATE INDEX incidents_node_id_idx ON incidents USING btree (node_id) ;

CREATE TABLE public.inst_def_mappings (
	id int8 NOT NULL DEFAULT nextval('inst_def_mappings_id_seq'::regclass),
	syst_id int8 NOT NULL,
	sys_ref varchar(45) NOT NULL,
	name varchar(100) NOT NULL,
	inst_defn_id int8 NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "INDM_IDEF_FK1" ON inst_def_mappings USING btree (inst_defn_id) ;
CREATE INDEX "SYST_FK" ON inst_def_mappings USING btree (syst_id) ;

CREATE TABLE public.instrument_benchmarks (
	id int8 NOT NULL DEFAULT nextval('instrument_benchmarks_id_seq'::regclass),
	name varchar(100) NOT NULL,
	code varchar(10) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.instrument_defs (
	id int8 NOT NULL DEFAULT nextval('instrument_defs_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	name varchar(30) NOT NULL,
	"source" varchar(20) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.instruments (
	id int8 NOT NULL DEFAULT nextval('instruments_id_seq'::regclass),
	name varchar(250) NULL,
	short_name varchar(100) NULL,
	details varchar(500) NULL,
	symbol varchar(100) NULL,
	disp_order int4 NULL,
	"position" int8 NULL,
	mark_id int8 NOT NULL,
	syst_id int8 NOT NULL,
	sys_ref varchar(150) NULL,
	link_inst_id int8 NULL,
	synon_inst_id int8 NULL,
	maturity_label varchar(60) NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	fb_result varchar(150) NULL,
	"source" numeric(1) NOT NULL DEFAULT 1::numeric,
	visible numeric(1) NOT NULL DEFAULT 1::numeric,
	settled numeric(1) NOT NULL DEFAULT 0::numeric,
	"result" varchar(25) NULL,
	result_confirmed numeric(1) NOT NULL DEFAULT 0::numeric,
	place int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	idef_id int8 NULL,
	bench_inbe_id int8 NULL,
	selection_id int8 NULL,
	created timestamptz NULL DEFAULT now(),
	"attributes" varchar(255) NULL,
	comp_id int8 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (bench_inbe_id) REFERENCES instrument_benchmarks(id) MATCH FULL,
	FOREIGN KEY (idef_id) REFERENCES instrument_defs(id) MATCH FULL,
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (link_inst_id) REFERENCES instruments(id) MATCH FULL,
	FOREIGN KEY (mark_id) REFERENCES markets(id) MATCH FULL,
	FOREIGN KEY (selection_id) REFERENCES selections(id) MATCH FULL,
	FOREIGN KEY (synon_inst_id) REFERENCES instruments(id) MATCH FULL,
	FOREIGN KEY (syst_id) REFERENCES systems(id) MATCH FULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX instruments_link_inst_id_idx ON instruments USING btree (link_inst_id) ;
CREATE INDEX instruments_mark_id_deleted_idx ON instruments USING btree (mark_id, deleted) ;
CREATE INDEX instruments_modified_idx ON instruments USING btree (modified) ;
CREATE INDEX instruments_synon_inst_id_fkey ON instruments USING btree (synon_inst_id) ;

CREATE TABLE public.layout_modules (
	id int4 NOT NULL DEFAULT nextval('layout_modules_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.limit_tiers (
	id int8 NOT NULL DEFAULT nextval('limit_tiers_id_seq'::regclass),
	name varchar(50) NOT NULL,
	liab_limit_pcnt numeric NOT NULL,
	risk_limit_pcnt numeric NOT NULL,
	early_liab_limit_pcnt numeric NOT NULL,
	early_risk_limit_pcnt numeric NOT NULL,
	min_stake numeric NOT NULL,
	max_stake numeric NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.locales (
	id int4 NOT NULL DEFAULT nextval('locales_id_seq'::regclass),
	name varchar(30) NOT NULL,
	code varchar(15) NOT NULL,
	description varchar(50) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	UNIQUE (code),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.lottery_audits (
	id int8 NOT NULL DEFAULT nextval('lottery_audits_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.lottery_draws (
	id int8 NOT NULL DEFAULT nextval('lottery_draws_id_seq'::regclass),
	draw_key varchar(64) NULL,
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.lottery_market_results (
	id int8 NOT NULL DEFAULT nextval('lottery_market_results_id_seq'::regclass),
	mark_id int8 NOT NULL,
	"data" json NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (mark_id) REFERENCES lottery_markets(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX lottery_market_results_mark_id_idx ON lottery_market_results USING btree (mark_id) ;

CREATE TABLE public.lottery_markets (
	id int8 NOT NULL DEFAULT nextval('lottery_markets_id_seq'::regclass),
	draw_id int8 NOT NULL,
	"data" json NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (draw_id) REFERENCES lottery_draws(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX lottery_markets_draw_id_idx ON lottery_markets USING btree (draw_id) ;

CREATE TABLE public.lottery_types (
	id int4 NOT NULL DEFAULT nextval('lottery_types_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.mapping_markets (
	id int8 NOT NULL DEFAULT nextval('mapping_markets_id_seq'::regclass),
	syst_id int8 NOT NULL,
	sys_ref varchar(20) NOT NULL,
	name varchar(150) NOT NULL,
	sport varchar(64) NOT NULL,
	market_area varchar NOT NULL,
	line varchar(50) NULL,
	line_type bpchar(1) NULL,
	link_map_id int8 NULL,
	active numeric(1) NOT NULL DEFAULT 1,
	created timestamptz NOT NULL DEFAULT now(),
	modified timestamptz NOT NULL DEFAULT now(),
	display_order int4 NOT NULL DEFAULT 0,
	line_type_param varchar(20) NULL,
	oca int8 NULL DEFAULT 0,
	period_sequence varchar(20) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (link_map_id) REFERENCES mapping_markets(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.mapping_selections (
	id int8 NOT NULL DEFAULT nextval('mapping_selections_id_seq'::regclass),
	syst_id int8 NOT NULL,
	sys_ref varchar(150) NOT NULL,
	name varchar(150) NOT NULL,
	market_id int8 NULL,
	link_map_id int8 NULL,
	active numeric(1) NOT NULL DEFAULT 1,
	created timestamptz NOT NULL DEFAULT now(),
	modified timestamptz NOT NULL DEFAULT now(),
	display_order int4 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (link_map_id) REFERENCES mapping_selections(id),
	FOREIGN KEY (market_id) REFERENCES mapping_markets(id),
	FOREIGN KEY (syst_id) REFERENCES systems(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_areas (
	id int8 NOT NULL DEFAULT nextval('market_areas_id_seq'::regclass),
	name varchar(45) NOT NULL,
	code varchar(20) NOT NULL,
	maar_id int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	def_mkt_type varchar(4) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "MAAR_MAAR_FK1" ON market_areas USING btree (maar_id) ;

CREATE TABLE public.market_availability (
	id int8 NOT NULL DEFAULT nextval('market_availability_id_seq'::regclass),
	"path" varchar(255) NULL,
	entity_type varchar(100) NULL,
	dest_avail int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_data_fields (
	mark_id int8 NOT NULL DEFAULT 0::bigint,
	dafi_id int8 NOT NULL DEFAULT 0::bigint,
	PRIMARY KEY (dafi_id, mark_id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_market_data_fields_21" ON market_data_fields USING btree (dafi_id) ;
CREATE INDEX "Index_2" ON market_data_fields USING btree (mark_id) ;

CREATE TABLE public.market_display_groups_initialization (
	sport_code varchar(20) NOT NULL,
	sportsbook_display_group_name varchar(256) NOT NULL,
	display_order int2 NOT NULL DEFAULT 0,
	PRIMARY KEY (sport_code, sportsbook_display_group_name)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_families (
	id int2 NOT NULL DEFAULT nextval('market_families_id_seq'::regclass),
	name varchar(255) NOT NULL,
	market_types varchar(1024) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	maar_id int8 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (maar_id) REFERENCES market_areas(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX market_families_maar_id ON market_families USING btree (maar_id) ;

CREATE TABLE public.market_groups (
	id int8 NOT NULL DEFAULT nextval('market_groups_id_seq'::regclass),
	name varchar(50) NOT NULL,
	market_types varchar(5500) NOT NULL,
	liab_limit_pcnt numeric NOT NULL DEFAULT 100::numeric,
	risk_limit_pcnt numeric NOT NULL DEFAULT 100::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	maar_id int8 NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX market_groups_maar_id ON market_groups USING btree (maar_id) ;

CREATE TABLE public.market_groups_initialization (
	sport_code varchar(20) NOT NULL,
	market_group_name varchar(256) NOT NULL,
	liab_limit_pcnt int2 NOT NULL DEFAULT 100,
	risk_limit_pcnt int2 NOT NULL DEFAULT 100,
	PRIMARY KEY (sport_code, market_group_name)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_history (
	market_id int8 NULL,
	channel_id int8 NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	"data" json NOT NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX market_history_modified_market_id_idx ON market_history USING btree (modified DESC, market_id) ;

CREATE TABLE public.market_templates (
	id int8 NOT NULL DEFAULT nextval('market_templates_id_seq'::regclass),
	name_template varchar(150) NOT NULL,
	"type" varchar(20) NOT NULL,
	event_template_id int8 NOT NULL,
	display_order int8 NOT NULL,
	displayed numeric(1) NOT NULL,
	pre_match numeric(1) NOT NULL,
	in_play numeric(1) NOT NULL,
	properties varchar(2000) NULL DEFAULT NULL::character varying,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_templates_ftten (
	id int8 NULL,
	name_template varchar(150) NULL,
	"type" varchar(20) NULL,
	event_template_id int8 NULL,
	display_order int8 NULL,
	displayed numeric(1) NULL,
	pre_match numeric(1) NULL,
	in_play numeric(1) NULL,
	properties varchar(2000) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL DEFAULT now(),
	oca int8 NULL DEFAULT 0
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_translations (
	id int8 NOT NULL DEFAULT nextval('market_translations_id_seq'::regclass),
	market_id int8 NOT NULL,
	loca_id int4 NOT NULL,
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int2 NULL,
	long_name varchar(100) NULL,
	short_name varchar(50) NULL,
	very_short_name varchar(10) NULL,
	PRIMARY KEY (market_id, loca_id),
	FOREIGN KEY (loca_id) REFERENCES locales(id),
	FOREIGN KEY (market_id) REFERENCES markets(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.market_types (
	id int8 NOT NULL DEFAULT nextval('market_types_id_seq'::regclass),
	name varchar(255) NOT NULL,
	code varchar(100) NOT NULL,
	displayed int2 NOT NULL DEFAULT 1,
	default_market_name varchar(255) NULL,
	display_order int8 NULL,
	inplay int2 NOT NULL DEFAULT 0,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	outright numeric(1) NOT NULL DEFAULT 0,
	maar_id int8 NULL,
	dedicated numeric(1) NOT NULL DEFAULT 0,
	line_type varchar(10) NULL,
	balanced_market numeric(1) NOT NULL DEFAULT 0::numeric,
	asian_handicap numeric(1) NOT NULL DEFAULT 0,
	period_sequence varchar(20) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (maar_id) REFERENCES market_areas(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX market_types_code_period_sequence_idx ON market_types USING btree (code, period_sequence) ;

CREATE TABLE public.market_types_initialization (
	sport_code varchar(20) NOT NULL,
	market_type_code varchar(256) NOT NULL,
	market_type_name varchar(256) NOT NULL,
	display_order int2 NOT NULL DEFAULT 0,
	market_group_name varchar(40) NOT NULL,
	sportsbook_display_group_name varchar(40) NOT NULL,
	key_market bool NOT NULL,
	inplay_key_market bool NOT NULL,
	PRIMARY KEY (market_type_code)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.markets (
	id int8 NOT NULL DEFAULT nextval('markets_id_seq'::regclass),
	name varchar(200) NOT NULL,
	sys_mrkt_name varchar(150) NULL,
	disp_order int4 NULL,
	state varchar(10) NULL,
	mrkt_type varchar(50) NULL,
	node_id int8 NULL,
	prod_id int8 NULL,
	maar_id int8 NULL,
	syst_id int8 NOT NULL,
	sys_ref varchar(150) NULL,
	sys_mrkt_type varchar(50) NULL,
	orig_mark_id int8 NULL,
	link_mark_id int8 NULL,
	auth_defb_id int8 NULL,
	alse_id int8 NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	"source" numeric(1) NOT NULL DEFAULT 1::numeric,
	visible numeric(1) NOT NULL DEFAULT 1::numeric,
	published numeric(1) NOT NULL DEFAULT 0::numeric,
	bir numeric(1) NOT NULL DEFAULT 0::numeric,
	each_way_available numeric(1) NOT NULL DEFAULT 0::numeric,
	each_way_places int8 NULL,
	double_resulting numeric(1) NOT NULL DEFAULT 0::numeric,
	settled numeric(1) NOT NULL DEFAULT 0::numeric,
	result_confirmed numeric(1) NOT NULL DEFAULT 0::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	mpath varchar(100) NULL,
	blurb varchar(255) NULL,
	handicap varchar(50) NULL,
	created timestamptz NULL DEFAULT now(),
	"attributes" varchar(2000) NULL,
	outright numeric(1) NULL,
	algo_mrkt_key varchar(50) NULL,
	last_bet_settled_time timestamptz NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (link_mark_id) REFERENCES markets(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (node_id) REFERENCES nodes(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (syst_id) REFERENCES systems(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_market_61" ON markets USING btree (link_mark_id) ;
CREATE INDEX markets_link_mark_id_fk ON markets USING btree (syst_id) ;
CREATE INDEX markets_modified_idx ON markets USING btree (modified) ;
CREATE INDEX markets_node_id_idx ON markets USING btree (node_id) ;
CREATE INDEX markets_nodeid_state_deleted_idx ON markets USING btree (node_id, state, deleted) WHERE ((deleted = (0)::numeric) AND ((state)::text = ANY (ARRAY[('OPEN'::character varying)::text, ('SUSPENDED'::character varying)::text]))) ;
CREATE INDEX markets_sys_ref_idx ON markets USING btree (sys_ref) ;

CREATE TABLE public.markets_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	name varchar(200) NULL,
	sys_mrkt_name varchar(150) NULL,
	disp_order int4 NULL,
	state varchar(10) NULL,
	mrkt_type varchar(50) NULL,
	node_id int8 NULL,
	prod_id int8 NULL,
	maar_id int8 NULL,
	syst_id int8 NULL,
	sys_ref varchar(150) NULL,
	sys_mrkt_type varchar(50) NULL,
	orig_mark_id int8 NULL,
	link_mark_id int8 NULL,
	auth_defb_id int8 NULL,
	alse_id int8 NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	"source" numeric(1) NULL,
	visible numeric(1) NULL,
	published numeric(1) NULL,
	bir numeric(1) NULL,
	each_way_available numeric(1) NULL,
	each_way_places int8 NULL,
	double_resulting numeric(1) NULL,
	settled numeric(1) NULL,
	result_confirmed numeric(1) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL,
	mpath varchar(100) NULL,
	blurb varchar(255) NULL,
	handicap varchar(50) NULL,
	created timestamptz NULL,
	"attributes" varchar(2000) NULL,
	outright numeric(1) NULL,
	algo_mrkt_key varchar(50) NULL,
	last_bet_settled_time timestamptz NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.match_incidents (
	node_id int8 NOT NULL,
	incident_id varchar(150) NOT NULL,
	undo numeric(1) NULL,
	incident json NULL,
	created timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (node_id, incident_id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX match_incidents_node_id_idx ON match_incidents USING btree (node_id) ;

CREATE TABLE public.match_states (
	node_id int8 NOT NULL,
	state json NULL,
	params json NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	match_results json NULL,
	PRIMARY KEY (node_id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.match_states_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	node_id int8 NULL,
	state json NULL,
	params json NULL,
	modified timestamptz NULL,
	match_results json NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX match_states_history_clock_timestamp_idx ON match_states_history USING btree (clock_timestamp) ;

CREATE TABLE public.message_history (
	acc_id int8 NULL,
	message_time timestamptz NOT NULL,
	priority int2 NULL,
	"data" json NOT NULL,
	sender_acc_id int8 NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX message_history_modifier_acc_id_idx ON message_history USING btree (acc_id) ;

CREATE TABLE public.messages (
	id int8 NOT NULL DEFAULT nextval('messages_id_seq'::regclass),
	message varchar(1000) NOT NULL,
	created timestamp NULL DEFAULT now(),
	added_by varchar(200) NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.node_competitors (
	comp_id int8 NOT NULL,
	cono_id int8 NOT NULL,
	PRIMARY KEY (comp_id, cono_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (cono_id) REFERENCES nodes(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.node_translations (
	id int8 NOT NULL DEFAULT nextval('node_translations_id_seq'::regclass),
	node_id int8 NOT NULL,
	loca_id int4 NOT NULL,
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int2 NULL DEFAULT 0,
	long_name varchar(100) NOT NULL,
	short_name varchar(50) NULL,
	very_short_name varchar(10) NULL,
	"type" varchar(20) NULL,
	PRIMARY KEY (node_id, loca_id),
	FOREIGN KEY (loca_id) REFERENCES locales(id),
	FOREIGN KEY (node_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.nodes (
	id int8 NOT NULL DEFAULT nextval('nodes_id_seq'::regclass),
	name varchar(150) NOT NULL,
	"type" varchar(20) NOT NULL,
	disp_order int4 NULL,
	node_id int8 NULL,
	state varchar(15) NOT NULL,
	man_state varchar(15) NULL,
	maar_id int8 NULL,
	maar_root numeric(4) NOT NULL DEFAULT 0::numeric,
	syst_id int8 NOT NULL,
	sys_ref varchar(150) NULL,
	link_node_id int8 NULL,
	alse_id int8 NULL,
	event_time timestamptz NULL,
	man_event_time numeric(1) NOT NULL DEFAULT 0::numeric,
	start_time timestamptz NULL,
	close_time timestamptz NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	"source" numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	npath varchar(100) NULL,
	managed numeric(1) NOT NULL DEFAULT 0::numeric,
	blurb varchar(255) NULL,
	node_level int8 NULL DEFAULT 0::bigint,
	"attributes" varchar(2000) NULL,
	created timestamptz NULL DEFAULT now(),
	priced numeric(1) NULL DEFAULT 0::numeric,
	outright numeric(1) NULL,
	cms_maar_id int8 NULL,
	competitor_a int8 NULL,
	competitor_b int8 NULL,
	PRIMARY KEY (id),
	CHECK (((state)::text = ANY ((ARRAY['ACTIVE'::character varying, 'STARTED'::character varying, 'VOID'::character varying, 'IN_ACTIVE'::character varying, 'SUSPENDED'::character varying, 'CLOSED'::character varying, 'COMPLETED'::character varying])::text[]))),
	CHECK (((type)::text = ANY ((ARRAY['TRADING'::character varying, 'NON_TRADING'::character varying])::text[]))),
	FOREIGN KEY (alse_id) REFERENCES algo_settings(id) MATCH FULL,
	FOREIGN KEY (cms_maar_id) REFERENCES market_areas(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (link_node_id) REFERENCES nodes(id) MATCH FULL,
	FOREIGN KEY (maar_id) REFERENCES market_areas(id) MATCH FULL,
	FOREIGN KEY (node_id) REFERENCES nodes(id) MATCH FULL,
	FOREIGN KEY (competitor_a) REFERENCES competitors(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (competitor_b) REFERENCES competitors(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (syst_id) REFERENCES systems(id) MATCH FULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX nodes_cms_maar_id_fkey_idx ON nodes USING btree (cms_maar_id) ;
CREATE INDEX nodes_deleted_source_lowername_idx ON nodes USING btree (deleted, source, lower((name)::text) varchar_pattern_ops) WHERE ((deleted = (0)::numeric) AND (source = (1)::numeric)) ;
CREATE INDEX nodes_event_time_syst_id_deleted_idx ON nodes USING btree (event_time DESC NULLS LAST, syst_id, deleted) ;
CREATE INDEX nodes_id_state_idx ON nodes USING btree (id, state) WHERE ((state)::text = 'COMPLETED'::text) ;
CREATE INDEX nodes_link_node_id_fkey_idx ON nodes USING btree (link_node_id) ;
CREATE INDEX nodes_maar_id_fkey_idx ON nodes USING btree (maar_id) ;
CREATE INDEX nodes_name_source_idx ON nodes USING btree (name varchar_pattern_ops, source) ;
CREATE INDEX nodes_node_id_fkey_idx ON nodes USING btree (node_id) ;
CREATE INDEX nodes_npath_idx ON nodes USING btree (npath varchar_pattern_ops) ;
CREATE INDEX nodes_state_idx ON nodes USING btree (state) WHERE ((state)::text = 'COMPLETED'::text) ;
CREATE INDEX nodes_sys_ref_idx ON nodes USING btree (sys_ref) ;
CREATE INDEX nodes_syst_id_created_idx ON nodes USING btree (syst_id, created) ;
CREATE INDEX nodes_type_deleted_syst_id_idx ON nodes USING btree (type, deleted, syst_id) WHERE (((type)::text = 'TRADING'::text) AND (deleted = (0)::numeric)) ;
CREATE INDEX nodes_type_systid_deleted_managed_priced_id_state_maarid_idx ON nodes USING btree (type, syst_id, deleted, managed, priced, id, state, maar_id) WHERE (((type)::text = 'TRADING'::text) AND (syst_id = 1) AND (deleted = (0)::numeric) AND (managed = (1)::numeric) AND (priced = (1)::numeric) AND ((state)::text = ANY (ARRAY[('ACTIVE'::character varying)::text, ('SUSPENDED'::character varying)::text]))) ;
CREATE INDEX nodes_type_systid_state_maarid_idx ON nodes USING btree (type, syst_id, state, maar_id) WHERE (((type)::text = 'TRADING'::text) AND (syst_id = 1) AND ((state)::text = 'COMPLETED'::text) AND (maar_id = 3)) ;

CREATE TABLE public.nodes_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	name varchar(150) NULL,
	"type" varchar(20) NULL,
	disp_order int4 NULL,
	node_id int8 NULL,
	state varchar(15) NULL,
	man_state varchar(15) NULL,
	maar_id int8 NULL,
	maar_root numeric(4) NULL,
	syst_id int8 NULL,
	sys_ref varchar(150) NULL,
	link_node_id int8 NULL,
	alse_id int8 NULL,
	event_time timestamptz NULL,
	man_event_time numeric(1) NULL,
	start_time timestamptz NULL,
	close_time timestamptz NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	active numeric(1) NULL,
	"source" numeric(1) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL,
	npath varchar(100) NULL,
	managed numeric(1) NULL,
	blurb varchar(255) NULL,
	node_level int8 NULL,
	"attributes" varchar(2000) NULL,
	created timestamptz NULL,
	priced numeric(1) NULL,
	outright numeric(1) NULL,
	cms_maar_id int8 NULL,
	competitor_a int8 NULL,
	competitor_b int8 NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX nodes_history_id_idx ON nodes_history USING btree (id) ;

CREATE TABLE public.organisation_unit_settings (
	id int8 NOT NULL DEFAULT nextval('organisation_unit_settings_id_seq'::regclass),
	epath varchar(100) NOT NULL,
	setting_value varchar(100) NOT NULL,
	setting_key varchar(100) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.organisation_units (
	id int8 NOT NULL DEFAULT nextval('organisation_units_id_seq'::regclass),
	name varchar(60) NOT NULL,
	"type" varchar(15) NULL,
	code varchar(25) NULL,
	short_name varchar(15) NULL,
	orga_id int8 NULL,
	orun_id int8 NULL,
	sys_ref varchar(45) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	oupath varchar(100) NULL,
	org_type varchar(15) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_organisation_unit_11" ON organisation_units USING btree (orga_id) ;
CREATE INDEX "FK_organisation_unit_21" ON organisation_units USING btree (orun_id) ;

CREATE TABLE public.organisations (
	id int8 NOT NULL DEFAULT nextval('organisations_id_seq'::regclass),
	name varchar(60) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.payment_options (
	id int4 NOT NULL DEFAULT nextval('payment_options_id_seq'::regclass),
	acco_id int8 NOT NULL,
	token varchar(64) NOT NULL,
	"type" varchar(32) NOT NULL,
	info_json json NOT NULL,
	gateway varchar(50) NULL,
	merchant_ref varchar(100) NULL,
	hidden numeric(1) NULL DEFAULT 0,
	blocked numeric(1) NULL DEFAULT 0,
	created timestamptz NULL DEFAULT now(),
	deleted numeric(1) NULL DEFAULT 0,
	FOREIGN KEY (acco_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.period_codes (
	id int4 NOT NULL DEFAULT nextval('period_codes_id_seq'::regclass),
	code varchar(32) NULL,
	name varchar(128) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.player_codes (
	id int4 NOT NULL DEFAULT nextval('player_codes_id_seq'::regclass),
	code varchar(32) NULL,
	name varchar(32) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.players (
	comp_id int8 NOT NULL,
	dateofbirth date NULL,
	nationality int8 NULL,
	sport varchar(50) NULL DEFAULT NULL::character varying,
	"position" varchar(100) NULL DEFAULT NULL::character varying,
	created timestamptz NULL DEFAULT now(),
	PRIMARY KEY (comp_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.players_temp (
	comp_id int8 NULL,
	dateofbirth date NULL,
	nationality int8 NULL,
	sport varchar(50) NULL,
	"position" varchar(100) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.price_maint_audits (
	id int8 NOT NULL DEFAULT nextval('price_maint_audits_id_seq'::regclass),
	modified timestamptz NOT NULL DEFAULT now(),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	defb_id int8 NOT NULL DEFAULT 0::bigint,
	user_id int8 NOT NULL DEFAULT 0::bigint,
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "PRMA_DEFB_FK" ON price_maint_audits USING btree (defb_id) ;

CREATE TABLE public.products (
	id int8 NOT NULL DEFAULT nextval('products_id_seq'::regclass),
	name varchar(45) NOT NULL,
	code varchar(20) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.promotions (
	id int4 NOT NULL DEFAULT nextval('promotions_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX promotions_expr_idx ON promotions USING btree ((((data -> 'Promotions'::text) ->> 'region'::text))) ;

CREATE TABLE public.psl_settings (
	id int4 NOT NULL DEFAULT nextval('psl_settings_id_seq'::regclass),
	name varchar(30) NULL,
	psl_group numeric(1) NULL,
	market_type varchar(10) NULL,
	min_threshold varchar(10) NULL,
	max_threshold varchar(10) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0,
	modified timestamptz NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	check_by varchar(10) NULL,
	channel_code varchar(10) NULL,
	suspend_market varchar(5) NULL,
	suspend_selection varchar(5) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX psl_setting_unique_market_type_idx ON psl_settings USING btree (market_type) ;

CREATE TABLE public.punter_limit_tiers (
	id int4 NOT NULL DEFAULT nextval('punter_limit_tiers_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.quick_links (
	id int4 NOT NULL DEFAULT nextval('quick_links_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX quick_links_expr_idx ON quick_links USING btree ((((data -> 'QuickLinks'::text) ->> 'region'::text))) ;

CREATE TABLE public.race_progress (
	id int4 NOT NULL DEFAULT nextval('race_progress_id_seq'::regclass),
	"type" varchar(64) NOT NULL,
	sys_ref varchar(150) NULL,
	sys_code varchar(50) NULL,
	created timestamptz NULL DEFAULT now(),
	deleted numeric(1) NULL DEFAULT 0,
	info text NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX race_progress_sys_ref_sys_code_idx ON race_progress USING btree (sys_ref, sys_code) ;

CREATE TABLE public.race_results (
	id int4 NOT NULL DEFAULT nextval('race_results_id_seq'::regclass),
	race_id int8 NOT NULL,
	"result" varchar NOT NULL,
	"source" varchar(64) NULL,
	created timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.regional_paths_config (
	id int4 NOT NULL DEFAULT nextval('regional_paths_config_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX regional_paths_config_expr_expr1_idx ON regional_paths_config USING btree ((((data -> 'RegionalConfig'::text) ->> 'sport'::text)), (((data -> 'RegionalConfig'::text) ->> 'region'::text))) ;

CREATE TABLE public.regions (
	id int8 NOT NULL DEFAULT nextval('regions_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	parent_id int8 NULL,
	name varchar(150) NOT NULL,
	code varchar(50) NOT NULL,
	"type" varchar(50) NULL DEFAULT NULL::character varying,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_regions_11" ON regions USING btree (parent_id) ;
CREATE UNIQUE INDEX "FK_regions_12" ON regions USING btree (code) ;

CREATE TABLE public.retailers (
	id int8 NOT NULL DEFAULT nextval('retailers_id_seq'::regclass),
	retailer_status varchar(20) NOT NULL,
	betting_vertical_status varchar(20) NOT NULL,
	location text NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.risk_alerts (
	id int8 NOT NULL DEFAULT nextval('risk_alerts_id_seq'::regclass),
	bet_id int8 NULL,
	bet_placed timestamptz NULL,
	punter varchar(50) NULL,
	punter_id varchar(50) NULL,
	punter_colour varchar(50) NULL,
	node_id int8 NULL,
	market_id int8 NULL,
	instrument_id int8 NULL,
	sport varchar(50) NULL,
	competition varchar(150) NULL,
	event varchar(150) NULL,
	market varchar(150) NULL,
	selection varchar(250) NULL,
	alert_type varchar(50) NULL,
	details varchar(2000) NULL,
	channel_id int4 NULL,
	ignore numeric(1) NOT NULL DEFAULT 0::numeric,
	alert_on numeric(1) NOT NULL DEFAULT 0::numeric,
	live_bet numeric(1) NULL DEFAULT 0::numeric,
	checked numeric(1) NOT NULL DEFAULT 0::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	creation_time timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.risk_groups (
	id int8 NOT NULL DEFAULT nextval('risk_groups_id_seq'::regclass),
	name varchar(50) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.risk_incidents (
	id int8 NOT NULL DEFAULT nextval('risk_incidents_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	trader_id int8 NULL,
	start_time timestamptz NULL DEFAULT now(),
	end_time timestamptz NULL DEFAULT now(),
	notes varchar(300) NULL,
	trigger_bet_rej_id int8 NULL,
	node_id int8 NULL,
	market_id int8 NULL,
	instrument_id int8 NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.roles (
	id int8 NOT NULL DEFAULT nextval('roles_id_seq'::regclass),
	role_type varchar(60) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.saved_betslips (
	id int4 NOT NULL DEFAULT nextval('saved_betslips_id_seq'::regclass),
	"data" json NULL,
	deleted numeric(1) NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.selection_groups (
	id int4 NOT NULL DEFAULT nextval('selection_groups_id_seq'::regclass),
	code varchar(64) NULL,
	name varchar(64) NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.selection_history (
	instrument_id int8 NULL,
	channel_id int8 NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	"data" json NOT NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX selection_history_instrumentid_modified_idx ON selection_history USING btree (instrument_id, modified) ;
CREATE INDEX selection_history_modified_instrument_id_idx ON selection_history USING btree (modified DESC, instrument_id) ;

CREATE TABLE public.selection_types (
	id int4 NOT NULL DEFAULT nextval('selection_types_id_seq'::regclass),
	name varchar(255) NOT NULL,
	code varchar(150) NULL,
	default_selection_name varchar(255) NULL,
	maty_id int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	selection_group varchar(64) NULL,
	display_order int4 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (maty_id) REFERENCES market_types(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX selection_types_code_selection_group_display_order_idx ON selection_types USING btree (code, selection_group, display_order) ;

CREATE TABLE public.selections (
	id int8 NOT NULL DEFAULT nextval('selections_id_seq'::regclass),
	name varchar(150) NOT NULL,
	"type" varchar(20) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.server_type_settings (
	server_type_id int8 NOT NULL,
	included_categories text NULL,
	excluded_categories text NULL,
	included_settings text NULL,
	excluded_settings text NULL,
	eagerly_loaded_settings text NULL,
	PRIMARY KEY (server_type_id),
	FOREIGN KEY (server_type_id) REFERENCES server_types(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.server_types (
	id int8 NOT NULL,
	type_name varchar(50) NULL,
	code varchar(20) NULL,
	srv_ids text NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.setting_types (
	id int8 NOT NULL DEFAULT nextval('setting_types_id_seq'::regclass),
	"type" varchar(20) NOT NULL,
	category varchar(50) NOT NULL,
	name varchar(100) NOT NULL,
	setting_key varchar(100) NOT NULL,
	default_value varchar(1750) NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX setting_types_category_setting_key_idx ON setting_types USING btree (category, setting_key) ;

CREATE TABLE public.settings_display_config (
	id int8 NOT NULL DEFAULT nextval('settings_display_config_id_seq'::regclass),
	description varchar(500) NOT NULL,
	group_key varchar(20) NOT NULL,
	setting_key varchar(100) NOT NULL,
	setting_category varchar(100) NOT NULL,
	value_type varchar(50) NOT NULL,
	display_path varchar(50) NOT NULL,
	additional json NOT NULL DEFAULT '{}'::json,
	active numeric(1) NOT NULL DEFAULT 1,
	parent_id int8 NULL,
	deleted numeric(1) NOT NULL DEFAULT 0,
	oca int2 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	UNIQUE (group_key, display_path),
	PRIMARY KEY (id),
	FOREIGN KEY (parent_id) REFERENCES settings_display_config(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.settings_template_types (
	id int4 NOT NULL DEFAULT nextval('settings_template_types_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.settings_templates (
	id int4 NOT NULL DEFAULT nextval('settings_templates_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.settings_templates_schedule (
	id int4 NOT NULL DEFAULT nextval('settings_templates_schedule_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.shadow_accounts (
	id int4 NOT NULL DEFAULT nextval('shadow_accounts_id_seq'::regclass),
	"data" json NULL,
	acco_id int8 NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX shadow_accounts_json_reversename_idx ON shadow_accounts USING btree ((((data -> 'ShadowAccount'::text) ->> 'reverseName'::text))) ;

CREATE TABLE public.sportsbook_settings (
	id int4 NOT NULL DEFAULT nextval('sportsbook_settings_id_seq'::regclass),
	"data" json NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.stage_of_competitions (
	id int8 NOT NULL DEFAULT nextval('stage_of_competitions_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	name varchar(255) NULL,
	code varchar(50) NULL,
	betclic_id int8 NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.systems (
	id int8 NOT NULL DEFAULT nextval('systems_id_seq'::regclass),
	name varchar(45) NOT NULL,
	code varchar(20) NOT NULL,
	"source" numeric(1) NOT NULL DEFAULT 0::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	PRIMARY KEY (id),
	UNIQUE (code)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.t1 (
	f1 int4 NULL
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.teams (
	comp_id int8 NOT NULL,
	code varchar(50) NULL,
	country int8 NULL,
	homevenue int8 NULL,
	sport varchar(50) NULL,
	created timestamptz NULL DEFAULT now(),
	PRIMARY KEY (comp_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX bein_n1 ON teams USING btree (country) ;
CREATE INDEX bein_n2 ON teams USING btree (homevenue) ;

CREATE TABLE public.tennis_match_statistics (
	tournament varchar(100) NOT NULL,
	surface varchar(15) NOT NULL,
	player_a_id int8 NOT NULL,
	player_b_id int8 NOT NULL,
	player_a_rank int2 NULL,
	player_b_rank int2 NULL,
	match_date date NOT NULL,
	first_set_player_a_games int2 NOT NULL,
	first_set_player_b_games int2 NOT NULL,
	second_set_player_a_games int2 NOT NULL,
	second_set_player_b_games int2 NOT NULL,
	third_set_player_a_games int2 NULL,
	third_set_player_b_games int2 NULL,
	fourth_set_player_a_games int2 NULL,
	fourth_set_player_b_games int2 NULL,
	fifth_set_player_a_games int2 NULL,
	fifth_set_player_b_games int2 NULL,
	num_first_serv_in_player_a int2 NULL,
	num_first_serv_player_a int2 NULL,
	num_win_first_serv_in_player_a int2 NULL,
	num_win_first_serv_player_a int2 NULL,
	num_win_second_serv_in_player_a int2 NULL,
	num_win_second_serv_player_a int2 NULL,
	num_breakpoints_won_player_a int2 NULL,
	num_breakpoints_player_a int2 NULL,
	num_received_won_player_a int2 NULL,
	num_received_player_a int2 NULL,
	points_won_player_a int2 NULL,
	points_total_player_a int2 NULL,
	num_first_serv_in_player_b int2 NULL,
	num_first_serv_player_b int2 NULL,
	num_win_first_serv_in_player_b int2 NULL,
	num_win_first_serv_player_b int2 NULL,
	num_win_second_serv_in_player_b int2 NULL,
	num_win_second_serv_player_b int2 NULL,
	num_breakpoints_won_player_b int2 NULL,
	num_breakpoints_player_b int2 NULL,
	num_received_won_player_b int2 NULL,
	num_received_player_b int2 NULL,
	points_won_player_b int2 NULL,
	points_total_player_b int2 NULL,
	id int8 NOT NULL DEFAULT nextval('tennis_match_statistics_id_seq'::regclass),
	deleted numeric(1) NOT NULL DEFAULT 0,
	oca int8 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	gender varchar(6) NOT NULL DEFAULT 'MALE'::character varying,
	doubles numeric(1) NOT NULL DEFAULT 0,
	tournament_id int8 NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (player_a_id, player_b_id, match_date, tournament_id),
	FOREIGN KEY (player_a_id) REFERENCES competitors_external_data(id),
	FOREIGN KEY (player_b_id) REFERENCES competitors_external_data(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.tennis_player_ratings (
	id int8 NOT NULL DEFAULT nextval('tennis_player_ratings_id_seq'::regclass),
	player_id int8 NOT NULL,
	surface varchar(5) NOT NULL DEFAULT 'GRASS'::character varying,
	gender varchar(6) NOT NULL DEFAULT 'MALE'::character varying,
	serve_r float8 NOT NULL,
	serve_rd float8 NOT NULL,
	return_r float8 NOT NULL,
	return_rd float8 NOT NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	deleted numeric(1) NOT NULL DEFAULT 0,
	doubles numeric(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	UNIQUE (player_id, surface),
	FOREIGN KEY (player_id) REFERENCES competitors(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.terms_and_conditions (
	id int4 NOT NULL DEFAULT nextval('terms_and_conditions_id_seq'::regclass),
	"data" text NOT NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.ticker_alert_attribute (
	id int8 NOT NULL DEFAULT nextval('ticker_alert_attribute_id_seq'::regclass),
	alert_id int8 NOT NULL DEFAULT nextval('ticker_alert_attribute_alert_id_seq'::regclass),
	attribute_name text NOT NULL,
	attribute_value text NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (alert_id) REFERENCES ticker_alerts(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX ticker_alert_attribute_alertid_idx ON ticker_alert_attribute USING btree (alert_id) ;

CREATE TABLE public.ticker_alert_audit (
	id int8 NOT NULL DEFAULT nextval('ticker_alert_audit_id_seq'::regclass),
	alert_id int8 NOT NULL DEFAULT nextval('ticker_alert_audit_alert_id_seq'::regclass),
	user_id int8 NULL,
	checked numeric(1) NOT NULL DEFAULT 0::numeric,
	"time" timestamptz NULL,
	comments varchar(500) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX ticker_alert_audit_alertid_idx ON ticker_alert_audit USING btree (alert_id) ;

CREATE TABLE public.ticker_alerts (
	id int4 NOT NULL DEFAULT nextval('ticker_alerts_id_seq'::regclass),
	node_id int8 NULL,
	checked numeric(1) NOT NULL DEFAULT 0::numeric,
	name varchar(400) NULL,
	description varchar(2000) NULL,
	created timestamptz NULL DEFAULT now(),
	category varchar(100) NULL,
	relevance varchar(25) NULL,
	severity int2 NULL,
	originator_reference varchar(50) NULL,
	originator_type varchar(20) NULL,
	in_play numeric(1) NULL DEFAULT 0,
	in_play_status varchar(20) NULL,
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX ticker_alerts_description_created_timeout_idx ON ticker_alerts USING btree (description, created) WHERE ((description)::text = 'Timeout'::text) ;
CREATE INDEX ticker_alerts_event_id_idx ON ticker_alerts USING btree (node_id) ;
CREATE INDEX tiker_alerts_nodeidnull_lowername_created_idx ON ticker_alerts USING btree (node_id, lower((name)::text) varchar_pattern_ops, created) WHERE (node_id IS NULL) ;

CREATE TABLE public.timeform (
	ats_id varchar(45) NOT NULL,
	"type" varchar(11) NOT NULL,
	ats_parent_id varchar(19) NULL,
	event_date date NOT NULL,
	"data" json NOT NULL,
	created timestamptz NULL DEFAULT now(),
	PRIMARY KEY (ats_id, event_date, type)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX timeform_ats_parent_id_idx ON timeform USING btree (ats_parent_id) ;
CREATE INDEX timeform_event_date_idx ON timeform USING btree (event_date) ;

CREATE TABLE public.tote_dividends (
	id int4 NOT NULL DEFAULT nextval('tote_dividends_id_seq'::regclass),
	node_id int8 NOT NULL,
	"data" json NOT NULL,
	FOREIGN KEY (node_id) REFERENCES nodes(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX tote_dividends_node_id_idx ON tote_dividends USING btree (node_id) ;

CREATE TABLE public.trader_comments (
	id int8 NOT NULL DEFAULT nextval('trader_comments_id_seq'::regclass),
	acco_id int8 NOT NULL,
	user_id int8 NOT NULL,
	comments varchar(6000) NULL,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	PRIMARY KEY (id),
	FOREIGN KEY (acco_id) REFERENCES accounts(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.trader_manual_changes (
	id int8 NOT NULL DEFAULT nextval('trader_manual_changes_id_seq'::regclass),
	node_id int8 NOT NULL,
	user_id int8 NOT NULL,
	detail varchar(2000) NOT NULL,
	oca int2 NOT NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	deleted numeric(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (node_id) REFERENCES nodes(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX trader_manual_changes_node_id_modified_idx ON trader_manual_changes USING btree (node_id, modified DESC NULLS LAST) ;

CREATE TABLE public.translations (
	english varchar(100) NOT NULL,
	locale varchar(8) NOT NULL,
	"translation" varchar(100) NOT NULL,
	PRIMARY KEY (english, locale)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.translations_arbitrary_text (
	id int4 NOT NULL DEFAULT nextval('translations_arbitrary_text_id_seq'::regclass),
	arte_id int8 NOT NULL,
	loca_id int4 NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	long_name varchar(400) NULL,
	short_name varchar(100) NULL,
	very_short_name varchar(50) NULL,
	PRIMARY KEY (arte_id, loca_id),
	FOREIGN KEY (arte_id) REFERENCES arbitrary_text(id),
	FOREIGN KEY (arte_id) REFERENCES arbitrary_text(id),
	FOREIGN KEY (loca_id) REFERENCES locales(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.translations_competitors (
	id int4 NOT NULL DEFAULT nextval('translations_competitors_id_seq'::regclass),
	loca_id int4 NOT NULL,
	comp_id int8 NOT NULL,
	long_name varchar(100) NULL,
	short_name varchar(50) NULL,
	very_short_name varchar(10) NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (comp_id, loca_id),
	FOREIGN KEY (comp_id) REFERENCES competitors(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (loca_id) REFERENCES locales(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.translations_market_types (
	id int4 NOT NULL DEFAULT nextval('translations_market_types_id_seq'::regclass),
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int2 NULL,
	market_type_code varchar(100) NOT NULL,
	description varchar(256) NULL,
	sequence_id varchar(50) NULL,
	subtype varchar(50) NULL,
	subtype_format varchar(50) NULL,
	loca_id int4 NULL,
	long_name varchar(200) NULL,
	short_name varchar(75) NULL,
	very_short_name varchar(50) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (loca_id) REFERENCES locales(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX translations_market_types_uniq_idx ON translations_market_types USING btree (market_type_code, (COALESCE(sequence_id, ''::character varying)), (COALESCE(subtype, ''::character varying)), loca_id) ;

CREATE TABLE public.translations_selection_types (
	id int4 NOT NULL DEFAULT nextval('translations_selection_types_id_seq'::regclass),
	deleted numeric(1) NULL DEFAULT 0,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int2 NOT NULL DEFAULT 0,
	selection_type_code varchar(100) NOT NULL,
	subtype varchar(50) NULL,
	subtype_format varchar(50) NULL,
	loca_id int4 NOT NULL,
	long_name varchar(100) NOT NULL,
	short_name varchar(50) NULL,
	very_short_name varchar(10) NULL,
	description varchar(256) NULL,
	market_type varchar(64) NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (loca_id) REFERENCES locales(id)
)
WITH (
	OIDS=FALSE
) ;
CREATE UNIQUE INDEX translations_selection_types_uniq_idx ON translations_selection_types USING btree ((COALESCE(market_type, ''::character varying)), selection_type_code, (COALESCE(subtype, ''::character varying)), loca_id) ;

CREATE TABLE public.user_group_members (
	user_id int8 NOT NULL,
	user_group_id int8 NOT NULL,
	PRIMARY KEY (user_id, user_group_id),
	FOREIGN KEY (user_group_id) REFERENCES user_groups(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
)
WITH (
	OIDS=FALSE
) ;

CREATE TABLE public.user_group_settings (
	id int8 NOT NULL DEFAULT nextval('user_group_settings_id_seq'::regclass),
	epath varchar(100) NOT NULL,
	setting_value varchar(255) NOT NULL,
	setting_key varchar(100) NOT NULL,
	active numeric(1) NOT NULL DEFAULT 1::numeric,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	UNIQUE (setting_key, epath)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX user_group_settings_deleted_epath_idx ON user_group_settings USING btree (deleted, epath) WHERE (deleted = (0)::numeric) ;

CREATE TABLE public.user_groups (
	id int8 NOT NULL DEFAULT nextval('user_groups_id_seq'::regclass),
	name varchar(60) NOT NULL,
	usgr_id int8 NULL,
	ugpath varchar(100) NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (usgr_id) REFERENCES user_groups(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_user_groups_11" ON user_groups USING btree (usgr_id) ;

CREATE TABLE public.user_market_area_permissions (
	user_id int8 NOT NULL DEFAULT 0::bigint,
	maar_id int8 NOT NULL DEFAULT 0::bigint,
	PRIMARY KEY (maar_id, user_id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_user_market_area_permissions_21" ON user_market_area_permissions USING btree (maar_id) ;

CREATE TABLE public.user_market_permissions (
	user_id int8 NOT NULL DEFAULT 0::bigint,
	mark_id int8 NOT NULL DEFAULT 0::bigint,
	PRIMARY KEY (mark_id, user_id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_user_market_permissions_21" ON user_market_permissions USING btree (mark_id) ;

CREATE TABLE public.user_preferences (
	id int8 NOT NULL DEFAULT nextval('user_preferences_id_seq'::regclass),
	user_id int8 NOT NULL DEFAULT 0::bigint,
	category varchar(50) NOT NULL,
	name varchar(100) NOT NULL,
	value varchar(10000) NOT NULL,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "USPR_USER_FK1" ON user_preferences USING btree (user_id) ;

CREATE TABLE public.user_roles (
	user_id int8 NOT NULL,
	role_id int8 NOT NULL,
	PRIMARY KEY (role_id, user_id),
	FOREIGN KEY (role_id) REFERENCES roles(id) DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_user_role_21" ON user_roles USING btree (role_id) ;

CREATE TABLE public.users (
	id int8 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
	name varchar(60) NULL,
	address1 varchar(45) NULL,
	address2 varchar(45) NULL,
	address3 varchar(45) NULL,
	address4 varchar(45) NULL,
	phone1 varchar(25) NULL,
	phone2 varchar(25) NULL,
	fax varchar(25) NULL,
	email1 varchar(45) NULL,
	email2 varchar(45) NULL,
	orun_id int8 NULL,
	usgr_id int8 NULL,
	username varchar(60) NULL,
	password varchar(60) NULL,
	password_history varchar(500) NULL,
	password_expiry timestamptz NULL,
	max_logins int8 NOT NULL DEFAULT 100::bigint,
	deleted numeric(1) NOT NULL DEFAULT 0::numeric,
	modified timestamptz NOT NULL DEFAULT now(),
	oca int8 NOT NULL DEFAULT 0,
	permissionable numeric(1) NOT NULL DEFAULT 1::numeric,
	alias varchar(60) NULL,
	client numeric(1) NOT NULL DEFAULT 0::numeric,
	sys_ref varchar(45) NULL,
	account_locked numeric(1) NOT NULL DEFAULT 0,
	attempts int8 NOT NULL DEFAULT 0,
	last_login_attempt timestamptz NULL DEFAULT now(),
	PRIMARY KEY (id)
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX "FK_user_11" ON users USING btree (orun_id) ;
CREATE INDEX "FK_user_21" ON users USING btree (usgr_id) ;

CREATE TABLE public.users_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	name varchar(60) NULL,
	address1 varchar(45) NULL,
	address2 varchar(45) NULL,
	address3 varchar(45) NULL,
	address4 varchar(45) NULL,
	phone1 varchar(25) NULL,
	phone2 varchar(25) NULL,
	fax varchar(25) NULL,
	email1 varchar(45) NULL,
	email2 varchar(45) NULL,
	orun_id int8 NULL,
	usgr_id int8 NULL,
	username varchar(60) NULL,
	password varchar(60) NULL,
	password_history varchar(500) NULL,
	password_expiry timestamptz NULL,
	max_logins int8 NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL,
	permissionable numeric(1) NULL,
	alias varchar(60) NULL,
	client numeric(1) NULL,
	sys_ref varchar(45) NULL,
	account_locked numeric(1) NULL,
	attempts int8 NULL,
	last_login_attempt timestamptz NULL
)
WITH (
	OIDS=FALSE
) ;
CREATE INDEX users_history_clock_timestamp_idx ON users_history USING btree (clock_timestamp) ;

CREATE TABLE public.wrong_event_templates_history (
	application_name varchar NULL,
	clock_timestamp timestamptz NULL,
	id int8 NULL,
	name varchar(150) NULL,
	sys_mrkt_name varchar(150) NULL,
	disp_order int4 NULL,
	state varchar(10) NULL,
	mrkt_type varchar(50) NULL,
	node_id int8 NULL,
	prod_id int8 NULL,
	maar_id int8 NULL,
	syst_id int8 NULL,
	sys_ref varchar(150) NULL,
	sys_mrkt_type varchar(50) NULL,
	orig_mark_id int8 NULL,
	link_mark_id int8 NULL,
	auth_defb_id int8 NULL,
	alse_id int8 NULL,
	ref1 varchar(60) NULL,
	ref2 varchar(60) NULL,
	ref3 varchar(60) NULL,
	ref4 varchar(60) NULL,
	ref5 varchar(60) NULL,
	"source" numeric(1) NULL,
	visible numeric(1) NULL,
	published numeric(1) NULL,
	bir numeric(1) NULL,
	each_way_available numeric(1) NULL,
	each_way_places int8 NULL,
	double_resulting numeric(1) NULL,
	settled numeric(1) NULL,
	result_confirmed numeric(1) NULL,
	deleted numeric(1) NULL,
	modified timestamptz NULL,
	oca int8 NULL,
	mpath varchar(100) NULL,
	blurb varchar(255) NULL,
	handicap varchar(20) NULL,
	created timestamptz NULL,
	"attributes" varchar(2000) NULL,
	outright numeric(1) NULL
)
WITH (
	OIDS=FALSE
) ;


-- Data --

INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(3,'Betdaq','BETDAQ',0,0)
,(4,'William Hill OP Manager','WHILL_OPMAN',0,0)
,(5,'Sporting Index','SINDEX',0,0)
,(6,'Reuters','RMDS',0,1)
,(7,'Universe','UNIVERSE',0,0)
,(9,'Supremacy','SUPRE',0,0)
,(10,'SBO Asian','SBOA',0,0)
,(12,'PM Derivator','PMDEV',0,0)
,(13,'Caerus','CAERUS',0,0)
,(123,'test','kkkkk',0,0)
;
INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(14,'Ibcbet','IBCBET',0,0)
,(20,'Betradar','BETRADAR',0,0)
,(8,'Orbis','ORBIS',0,0)
,(2,'Betfair','BETFAIR',0,0)
,(1,'ATS Platform','ATS',1,0)
,(21,'Geneity','GENEITY',0,0)
,(22,'Press Association','PRESS_ASSOCIATION',0,0)
,(23,'SIS 365','SIS',0,0)
,(15,'RunningBall','RUNNINGBALL',0,0)
,(11,'12Bet Asian','ONETWOBET',0,0)
;
INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(16,'DonBest','DONBEST',0,0)
,(125,'Enetpulse','ENETPULSE',0,0)
,(250,'Paddy Power','PADDY_POWER',0,0)
,(251,'Ladbrokes','LADBROKES',0,0)
,(252,'188 Bet','OEEBET',0,0)
,(253,'Bet 365','BET365',0,0)
,(254,'Boyle Sports','BOYLESPORTS',0,0)
,(255,'Industry','INDUSTRY',0,0)
,(24,'Gambit','GAMBIT',0,0)
,(25,'OnCourt Tennis Statistics','ONCOURT',0,0)
;
INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(26,'Abelson','ABELSON',0,0)
,(256,'Bet Victor','BETVICTOR',0,0)
,(28,'Betfair Exchange','BETFAIR_EXCHANGE',0,0)
,(257,'Tip-ex','TIPEX',0,0)
,(133,'Bet 365 Tennis','BET365_TEN',0,0)
,(134,'Paddy Power Tennis','PADDY_POWER_TEN',0,0)
,(258,'Bet Victor Horse Racing','BETVICTOR_HR',0,0)
,(135,'WilliamHill','WHILL',0,0)
,(136,'Futbol 24','FUTBOL24',0,0)
,(140,'Pokerstars','POKERSTARS',0,0)
;
INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(138,'Inplay Sports Data','ISD',0,0)
,(139,'SIS Soccer','SIS_SOCCER',0,0)
,(259,'Exalogic','EXALOGIC',0,0)
,(262,'Amelco','TIPEX_BETSYNC_RACING',0,0)
,(143,'ATS ALGO MGR','ATS_ALGO_MGR',0,0)
,(144,'At The Races','ATR',0,0)
,(145,'Cricket World','CRICKET_WORLD',0,0)
,(999,'Ats Sync','ATS_SYNC',0,0)
,(27,'Pinnacle Sports','PINNACLE',0,0)
,(146,'Skybet','SKYBET',0,0)
;
INSERT INTO public.systems (id,"name",code,"source",deleted) VALUES 
(149,'Performance Test','PT',0,0)
,(277,'Img','IMG',0,0)
,(151,'LSports','LSPORTS',0,0)
,(152,'Racing UK','RACING_UK',0,0)
,(263,'Betgenius Feed','BETGENIUS',0,0)
,(153,'Stats Core Game virtualisation','STATSCORE',0,0)
;
