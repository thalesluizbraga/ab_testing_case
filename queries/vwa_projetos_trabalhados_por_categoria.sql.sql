create view vwa_projetos_trabalhados_por_categoria as
with tb_skills as (
    select 
        id as skill_id,
        slug, 
        name as skill_name
    from skills 
    where id in (546,876,930,228,875,896,668,676,437,146,901,67,499,307,908,497,747,909,362,858)

),

tb_qtd_projetos as (
    select 
        a.worker_id,
        count(distinct a.project_id) as qtd_projetos,
        c.skill_id,
        c.skill_name
    from bids as a
    left join projects as b on a.project_id = b.id
    inner join tb_skills as c on b.skill_id = c.skill_id
    group by 
        a.worker_id, c.skill_id, c.skill_name
),

tb_ranking_por_skill as (
    select
        worker_id,
        qtd_projetos,
        skill_id,
        skill_name,
        dense_rank() over (partition by skill_id order by qtd_projetos desc) as rk
    from tb_qtd_projetos 
),

tb_agrupamentos as (
    select 
        skill_id,
        max(qtd_projetos) as max_qtd_projetos,
        min(qtd_projetos) as min_qtd_projetos,
        avg(qtd_projetos) as avg_qtd_projetos
    from tb_qtd_projetos
    group by skill_id
)
select 
    a.worker_id,
    a.qtd_projetos,
    a.skill_id,
    a.skill_name,
    a.rk,
    b.avg_qtd_projetos,
    case 
        when a.qtd_projetos > b.avg_qtd_projetos then 100 * 0.2
        else 50 * 0.2
    end as score_qtd_projetos_trabalhados_por_categoria
from tb_ranking_por_skill as a
left join tb_agrupamentos as b on a.skill_id = b.skill_id


