create table if not exists `puser` (
    
)engine=InnoDB default charset=utf8;

create table if not exists `porg` (
    `id` int(11) unsigned not null auto_increment,
    `name` varchar(64) not null unique,
    primary key (`id`)
)engine=InnoDB default charset=utf8;

create table if not exists `puser` (
    
)engine=InnoDB default charset=utf8;