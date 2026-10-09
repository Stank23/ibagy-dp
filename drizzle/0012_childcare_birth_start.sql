UPDATE childcare_children SET start=substr(birth_date,1,7),revision=revision+1 WHERE start!=substr(birth_date,1,7);
