#include <stdio.h>
#include <time.h>

void main()
{
	int inputs = 1000;
 	//srand(time(NULL));
	
  FILE *inputData, *expectedOutput;
	inputData = fopen("input_data.txt","w");
   
	expectedOutput = fopen("Expected_op_part1.txt", "w");
   if(expectedOutput== NULL)
   {
     printf("file does not exist");
   
   }

	fprintf(expectedOutput,"x\n0\n0\n0\n");
	int i ,valid_in ;
	signed int  a, b;
  signed int f;
  f=0;
	for(i=0;i<1000;i++)
	{
		a = (rand() % 512)-256;
		b = (rand() % 512) -256;
    
    valid_in=rand()%2;
    
    if (valid_in==1)
	  {
     f = f+(a*b);
		}
    else
    {
      f=f;
    }
    
    //printf("%d %d %d\n",a,b,valid_in,f);
		fprintf(inputData,"%x\n%x\n%x\n",((a>>0)&0x3ff),((b>>0)&0x3ff),valid_in);
		fprintf(expectedOutput, "%d\n",((f>>0)&0xfffff));
	}
  printf("Done");
	fclose(inputData);
	fclose(expectedOutput);

}