with tb_skills as (
-- cte com as skills cadastradas
select 
    id as skill_id,
    slug, 
    name
from 
   skills 
where 
    id in (546,876,930,228,875,896,668,676,437,146,901,67,499,307,908,497,747,909,362,858)
),

tb_projects as (
-- cte com os dados de projeto
select 
    id as project_id,
    user_id as worker_id,
    skill_id  
from 
    projects 
),

tb_bids as (
-- cte que agrupa bids por projeto para evitar duplicação
select 
    project_id,
    count(*) as total_bids,
    count(distinct worker_id) as unique_bidders
from 
    bids
group by 
    project_id
),

tb_accepted_bids as (
-- cte que agrupa accepted_bids por projeto para evitar duplicação
select 
    project_id,
    count(*) as total_accepted_bids
from 
    accepted_bids
group by 
    project_id

),

tb_ultimo_gamification_level as (
-- cte que traz o ultimo gamification level para cada worker 
select 
    project_id,
	worker_position_label as gamification_level,
	case 
		when lower(worker_position_label) = 'hero' then 100
		when lower(worker_position_label) = 'platinum' then 80
		when lower(worker_position_label) = 'gold' then 60
		when lower(worker_position_label) = 'silver' then 40
		when lower(worker_position_label) = 'bronze' then 20
		when lower(worker_position_label) = 'iron' then 10
		else 0
	end as score_gamification_level,
	row_number() over (partition by worker_id order by created desc) as rk
from 	
    bids

),

tb_metricas as (
-- cte com as metricas em uma tabela so
select 
    a.project_id, 
    a.worker_id,
    b.skill_id,
    b.name,
    case 
        when c.project_id is not null then 1 else 0 
    end as has_bids,
    c.total_bids,
    c.unique_bidders,
    case 
        when d.project_id is not null then 1 else 0 
    end as has_accepted_bids,
    d.total_accepted_bids,
    e.gamification_level,
	e.score_gamification_level
from 
    tb_projects as a 
left join 
    tb_skills as b on a.skill_id = b.skill_id
left join 
    tb_bids as c on a.project_id = c.project_id 
left join 
    tb_accepted_bids as d on a.project_id = d.project_id
left join 
	tb_ultimo_gamification_level as e on a.project_id = e.project_id

)

/*
tb_pesos_score as (

select  
    project_id, 
    worker_id,
    skill_id,
    name,
	has_bids,
    has_bids * 0.2,
    total_bids,
    unique_bidders,
	has_accepted_bids,
    has_accepted_bids * 0.2,
    total_accepted_bids,
	gamification_level,
    gamification_level * 0.3
from 
    tb_metricas

)

*/

select *
from
    tb_metricas

-- TEM QUE ALOAR PRA CADA METRICA OS PESOS