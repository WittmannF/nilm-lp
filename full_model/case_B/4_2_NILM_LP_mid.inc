for {t in TS2} {
   printf "%8d  %8.4f \n",t,DELTA_P[t] > z_results_delta.m;
   
   printf "%8d  ",t > z_results_x.m;
   for {e in ESTADO} {
	  printf "%1d  ",X[e,t] > z_results_x.m;;
   }   
   printf "\n" > z_results_x.m;
   
   printf "%8d  %8.4f \n",t,Ptotal[t] > z_results_ptotalorg.m;
   
}
