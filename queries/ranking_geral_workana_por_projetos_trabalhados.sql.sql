
create view vwa_projetos_trabalhados_por_categoria as 

with tb_qtd_projetos as (
-- cte que traz a qtd de projetos por codigo de skill
  select 
        a.worker_id,
        count(a.project_id) as qtd_projetos,
        c.id as skill_id,
        c.name
    from 
        bids as a
    left join 
        projects as b on a.project_id = b.id
    left join 
        skills as c on b.skill_id = c.id
    group by 
        a.worker_id,
        c.id,
        c.name

),

tb_ranking_geral_por_qtd_projetos_trabalhados as (
-- cte que traz o ranking de workers baseado na quantidade de projetos por skill. O ranking esta particionado por worker_id e skill_id
select
	  worker_id,
        qtd_projetos,
        skill_id,
        name,
        dense_rank() over (partition by skill_id order by qtd_projetos desc) as rk
from 
	tb_qtd_projetos 
	
),

tb_agrupamentos as (

select 
	skill_id,
	max(qtd_projetos) as max_qtd_projetos,
	min(qtd_projetos) as min_qtd_projetos,
	avg(qtd_projetos) as avg_qtd_projetos
from 
	tb_qtd_projetos
group by 
	skill_id
	
)

select 
	a.worker_id,
    a.qtd_projetos,
    a.skill_id,
    a.name,
    a.rk,
	-- escolhi essa forma de normalizaçao porque pelo min max zerava e os quartis estavam muito dispersos no q4 e q2. Isso tudo dado as baixas qtd de projetos
	case 
		when a.qtd_projetos > b.avg_qtd_projetos then 100 * 0.2
		else 50 * 0.2
	end as score_qtd_projetos_trabalhados_por_categoria 
from 
tb_ranking_geral_por_qtd_projetos_trabalhados as a
left join 
tb_agrupamentos as b on a.skill_id = b.skill_id
