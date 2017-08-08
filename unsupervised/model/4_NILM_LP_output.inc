for {t in TS2} {
   
   printf "%8d,  ",t >> z_results_x.csv;
   for {e in ESTADO} {
	  printf "%1d,  ",X[e,t] >> z_results_x.csv;;
   }   
   printf "\n" >> z_results_x.csv;

   
}
