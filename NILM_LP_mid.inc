for {t in TS2} {
   printf "%8d  %8.4f \n",t,DELTA_P[t] > delta.m;
   
   printf "%8d  ",t > x.m;
   for {e in ESTADO} {
	  printf "%1d  ",X[e,t] > x.m;;
   }   
   printf "\n" > x.m;
   
   printf "%8d  %8.4f \n",t,Ptotal[t] > ptotalorg.m;
   
}
