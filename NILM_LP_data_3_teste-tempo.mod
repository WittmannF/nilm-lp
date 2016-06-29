param: TS:  Ptotal:=
		1	0
		2	0
		3	0
		4	3000
		5	3000
		6	3000
		7	3000
		8	3000
		9	3000
		10	80
		11	80
		12	80
		13	80
		14	550
		15	550
		16	550
		17	550
		18	0
		19	0
		20	0
		21	0
		22	80
		23	80
		24	80
		25	80
		26	0
		27	0
		28	0
		29	0
		30	0;


param:  ESTADO: disp  ant  Pdisp  mindisc :=
#                            [W]  [amostras] 
        1        1     0     130    1
        2        2          3000    1
        3        2            80    1
        4        2           550    1
        5        3           850    1;

let numdisp := 3;

let disc_i :=1;
let window :=10;
		