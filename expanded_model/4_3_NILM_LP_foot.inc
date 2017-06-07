
printf "]; \n\n" > z_results_delta.m;
printf "return;\n\n" > z_results_delta.m;

printf "]; \n\n" > z_results_x.m;
printf "return;\n\n" > z_results_x.m;

printf "function [ESTADO] = estado(); \n\n" > z_results_estado.m;
printf "ESTADO = [ \n" > z_results_estado.m;
	for {e in ESTADO} {
	   printf "%3d  %8.2f \n",e,Pdisp[e] > z_results_estado.m;;
	}
printf "]; \n\n" > z_results_estado.m;
printf "return;\n\n" > z_results_estado.m;

printf "]; \n\n" > z_results_ptotalorg.m;
printf "return;\n\n" > z_results_ptotalorg.m;