/*  
 *                     Copyright (C) 2016 XFastMining Lab@Huaqiao university.
 *  
 *  This source code is free to use, distribute and modify only for personal
 *  use or research. Commercial application isn't allowed without permission.
 *
 *                                      Created by Yewang Chen, Shengyu Tang,
 *                                                           XFastMining Lab,
 *                                        @Huaqiao university, Xiamen, China.
 *                                                               Nov.18,2016
 */ 
#include "mex.h"
#include "math.h"
/*
 * find_halfspace_mex.c
 * same as find_halfspace.m
 */

int binary_search(double a[], int low, int high, double key) {
    //double key= target[0];
    int result=-1;
    int mid=-1;
    while (low <high){
        mid= (low + high)/2;
        if (a[mid]==key)
            return mid;
        else{
           if (a[mid]>key)
               high=mid-1;
           else
               low=mid+1;
        }
    }
    return low;
}
 
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{
    double *sortedValues,*points,*LowLocRecorder,*HighLocRecorder,*MinDimRecorder ;
    double *y, *target, *vec, *dCol,key1,key2, radius;
    int col, i ,j,k, lowLoc,highLoc,minnum,num,mindim;
    int mrows,ncols;
    //map<int,String> mapint;
 
    /* The input must be a noncomplex scalar double.*/
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
  
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
 
    y = mxGetPr(plhs[0]);
    

    /* Assign pointers to each input and output. */
    points = mxGetPr(prhs[0]);
    sortedValues = mxGetPr(prhs[1]);
    radius = *(mxGetPr(prhs[2]));
    LowLocRecorder=mxGetPr(prhs[3]);
    HighLocRecorder=mxGetPr(prhs[4]);
    MinDimRecorder=mxGetPr(prhs[5]);
    
    for (i=0; i<mrows;i++){
        minnum=mrows+1;
        num=0;
        mindim=0;
        for (j=0; j<ncols;j++){
            key1=*(points+j* mrows+i)-radius;
            key2=*(points+j* mrows+i)+radius;
            vec= sortedValues + j* mrows;
            lowLoc=binary_search(vec,0,mrows-1,key1);
            
            while (lowLoc>0&&*(sortedValues+j*mrows+lowLoc)==key1){
                lowLoc--;
            }
            
            if (*(sortedValues+j*mrows+lowLoc)<key1){
                lowLoc=lowLoc+1;
            }            
            
            *(LowLocRecorder+j* mrows+i)=lowLoc+1;
            highLoc=binary_search(vec,0,mrows-1,key2);
            while (highLoc<mrows-1 && *(sortedValues+j*mrows+highLoc)==key1){
                highLoc++;
            }
            
            if (*(sortedValues+j*mrows+highLoc)>key2){
                highLoc=highLoc-1;
            }
             *(HighLocRecorder+j* mrows+i)=highLoc+1;
            num=highLoc-lowLoc+1;
            if (minnum>num){
                minnum=num;
                mindim=j;
            }
        }
        *(MinDimRecorder+i)=mindim+1;
        *(MinDimRecorder+mrows+i)=minnum;
        
    }
    
    //arr = mxGetPr(prhs[0]);
    //target = mxGetPr(prhs[1]); 
    //dCol=mxGetPr(prhs[2]);
    //col=(int) (*dCol);
    //vec= arr + (col-1)* mrows;
    //y[0]=binary_search(vec,0,mrows-1,target);
}