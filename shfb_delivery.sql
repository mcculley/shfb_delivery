create type language as enum ('english', 'spanish', 'creole', 'portuguese');

create type staff_role as enum ('admin', 'driver');

create table staff_member
(
    id         serial not null
        constraint staff_member_pk
            primary key,
    name_first text   not null,
    name_last  text   not null
);

comment on table staff_member is 'A member of the SHFB staff responsible for triaging and updating a client.';

comment on column staff_member.id is 'The unique ID of the staff member.';

create unique index staff_member_id_uindex
    on staff_member (id);

create table client
(
	id serial not null
		constraint client_pk
			primary key,
	name_first text not null,
	name_last text not null,
	language language,
	phone text not null,
	street_address1 text not null,
	street_address2 text,
	city text not null,
	state text not null,
	ZIP text not null,
        has_private_transportation boolean not null,
	children integer not null
		constraint children_check
			check (children >= 0),
	adults integer not null
		constraint adult_check
			check (adults >= 0),
	seniors integer not null
		constraint seniors_check
			check (seniors >= 0),
        family_size integer generated always as (children + adults + seniors) stored,
		constraint family_size_check
			check (family_size >= 1),
	food_allergies text,
	created timestamp,
	note text
);

create unique index client_id_uindex
	on client (id);

comment on table client is 'A household requesting food delivery.';

comment on column client.adults is 'The number of non-senior adults in the home.';

comment on column client.seniors is 'The number of senior citizens in the home.';

comment on column client.children is 'The number of children in the home.';

comment on column client.family_size is 'The total number of people in the home (computed from the total number of children, adults, and seniors).';

comment on column client.note is 'Free form text about the client.';

create table eligibility_determination
(
	timestamp timestamp not null,
	client integer not null
		constraint eligibility_determination_client_id_fk
			references client
				on delete restrict,
	eligible boolean not null,
	note text,
        adjudicator integer not null
            constraint eligibility_determination_staff_member_id_fk
                references staff_member
                on delete restrict

);

comment on table eligibility_determination is 'A log of eligibility determinations for a client. If a client does not appear in this table, it needs to be triaged.';

comment on column eligibility_determination.timestamp is 'The timestamp of the determination.';

comment on column eligibility_determination.note is 'A free form note optionally entered by the staff member.';

create table client_update
(
    client  integer   not null
        constraint client_update_client_id_fk
            references client
            on delete restrict,
    editor    integer   not null
        constraint client_update_staff_member_id_fk
            references staff_member
            on delete restrict,
    timestamp timestamp not null,
    note      text
);

create table delivery
(
    client  integer   not null
        constraint delivery_client_id_fk
            references client
            on delete restrict,
    timestamp timestamp not null,
    note      text
);

create table staff_role_membership
(
    staff_member integer    not null
        constraint staff_role_staff_member_id_fk
            references staff_member
            on delete restrict,
    role         staff_role not null
);
