create type language as enum ('english', 'spanish', 'creole', 'portuguese');

create table customer
(
	name_first text not null,
	name_last text not null,
	id serial not null
		constraint customer_pk
			primary key,
	language language,
	children integer not null
		constraint children_check
			check (children >= 0),
	adults integer not null
		constraint adult_check
			check (adults >= 0),
	seniors integer not null
		constraint seniors_check
			check (seniors >= 0),
	created timestamp,
        family_size integer generated always as (children + adults + seniors) stored,
		constraint family_size_check
			check (family_size >= 1),
	updated timestamp
);

create unique index customer_id_uindex
	on customer (id);

comment on table customer is 'A household requesting food delivery.';

comment on column customer.adults is 'The number of non-senior adults in the home.';

comment on column customer.seniors is 'The number of senior citizens in the home.';

comment on column customer.children is 'The number of children in the home.';

comment on column customer.family_size is 'The total number of people in the home (computed from the total number of children, adults, and seniors).';

create table eligibility_determination
(
	timestamp timestamp not null,
	customer integer not null
		constraint eligibility_determination_customer_id_fk
			references customer
				on delete restrict,
	eligible boolean not null,
	note text
);
