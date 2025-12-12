
create view vwa_projetos_ganhos_por_subcategoria as 
with tb_qtd_projetos as (
    select 
        a.worker_id,
        count(a.project_id) as qtd_projetos,
		b.subcategory_id,
        --c.id as skill_id,
        c.name
    from 
        accepted_bids as a
    left join 
        projects as b on a.project_id = b.id
    left join 
        skills as c on b.skill_id = c.id
	where 
		1=1
		and c.id in (546,876,930,228,875,896,668,676,437,146,901,67,499,307,908,497,747,909,362,858)
		and a.status = 'active' -- somente bids que tiveram sucesso na negociaçao (nao foram revertidas ou mediadas)
    group by 
        a.worker_id,
		b.subcategory_id,
        --c.id,
        c.name
),

tb_ranking as (
    select
        worker_id,
        qtd_projetos,
		subcategory_id,
        --skill_id,
        name,
        dense_rank() over (partition by subcategory_id order by qtd_projetos desc) as rk
    from 
        tb_qtd_projetos 

),

tb_agrupamentos as (

select 
	subcategory_id,
	max(qtd_projetos) as max_qtd_projetos,
	min(qtd_projetos) as min_qtd_projetos,
	avg(qtd_projetos) as avg_qtd_projetos
from 
	tb_qtd_projetos
group by 
	subcategory_id
	
)

select 
    a.worker_id,
    a.qtd_projetos,
    a.subcategory_id,
    a.name,
    a.rk,
	-- escolhi essa forma de normalizaçao porque pelo min max zerava e os quartis estavam muito dispersos no q4 e q2. Isso tudo dado as baixas qtd de projetos
	case 
		when a.qtd_projetos > b.avg_qtd_projetos then 100 * 0.2
		else 50 * 0.2
	end as score_qtd_projetos_ganhos_por_subcategoria 
from 
    tb_ranking as a
left join 
	tb_agrupamentos as b on a.subcategory_id = b.subcategory_id
where 
    1=1
    --and a.skill_id = 437
