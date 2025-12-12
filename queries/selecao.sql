with tb_skills as (

select 
    id as skill_id,
    slug, 
    name
from 
   skills 
where 
    1=1 
    and id in (

546,
876,
930,
228,
875,
896,
668,
676,
437,
146,
901,
67,
499,
307,
908,
497,
747,
909,
362,
858   )

)

select * from tb_skills