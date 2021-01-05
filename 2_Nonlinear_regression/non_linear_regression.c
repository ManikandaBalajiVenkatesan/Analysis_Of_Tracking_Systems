#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define TOTAL_ITERATIONS    50000

void main (int argc, char *argv[])
{
    FILE *fpt;
    int lines = 1;      //number of data points
    double fan=0, fpan=0;
    double an, an1;     //unknown of current iteration and next iteration
    int k;

    if (argc != 2 )
        printf("Usage : <executable> <database>.txt");
    printf("file choosen is %s\n",argv[1]);
    fpt = fopen(argv[1],"r");
    if (fpt == NULL)
        printf("unable to open %s\n",argv[1]);
    char c ;
    while((c=fgetc(fpt)) != EOF)        //checking whether the character is End of file
        if (c == '\n')                  //when new line character comes number of lines is increased by 1
            lines+=1;
    fclose(fpt);
    fpt = fopen(argv[1],"r");
    float x[lines], y[lines];
    for(int i=0; i<lines; i++)
        k = fscanf(fpt,"%f %f",&x[i],&y[i]);
    fclose(fpt);
    
    // an = 10;      //initial value data a and b
    an = 0.4;     //initial value data c
    
    printf("initial an %lf ",an);
    int j;      //to keep track of iterations
    for(j=0; j<TOTAL_ITERATIONS; j++)
    {
        fan=0, fpan=0;
        for(int i=0; i<lines; i++)
        {
            fan+= ( log(an*x[i]) - y[i] ) / an;
            fpan+= ( 1 + y[i] - log(an*x[i]) ) / (an*an) ;
            //printf("%f\t%f\t%f\t%f\n", fan, fpan,x[i], y[i]);
        }
        
        an1 = an - fan/fpan;
        // printf("%f\t%f\n", an, an1);
        if (fabs(an1 - an) < 0.0001)
            break;
        an = an1;
    }
    printf("final an %lf \n",an);
    printf("Final difference %lf\n",fabs(an1 - an));
    printf("Number of iterations is %d\n",j);
    //printf("lines are %d\n",lines);
    //x[0] = 1; y[0] = 1;
    //printf("%f\t%f",x[0],y[0]);
    printf("success");
}
