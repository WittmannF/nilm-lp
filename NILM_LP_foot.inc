
printf "]; \n\n" > delta.m;
printf "return;\n\n" > delta.m;

printf "]; \n\n" > x.m;
printf "return;\n\n" > x.m;

printf "function [ESTADO] = estado(); \n\n" > estado.m;
printf "ESTADO = [ \n" > estado.m;
	for {e in ESTADO} {
	   printf "%3d  %8.2f \n",e,Pdisp[e] > estado.m;;
	}
printf "]; \n\n" > estado.m;
printf "return;\n\n" > estado.m;

printf "]; \n\n" > Ptotalorg.m;
printf "return;\n\n" > Ptotalorg.m;