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
    double *points,*ptr;
    double *keyPtr;
    int i,j, key,loc,lowLoc,highLoc;
    int mrows,ncols;
    //map<int,String> mapint;
 
    /* The input must be a noncomplex scalar double.*/
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    

    /* Assign pointers to each input and output. */
    points = mxGetPr(prhs[0]);
    keyPtr = mxGetPr(prhs[1]);

    key=*keyPtr;
    
    loc=binary_search(points,0,mrows-1,key);
    lowLoc=loc;
    highLoc=loc;
            
    while (lowLoc>0&&points[lowLoc]==key){
        lowLoc--;
    }
    
    if (points[lowLoc]<key){
        lowLoc=lowLoc+1;
    }            

   
    while (highLoc<mrows-1 && points[highLoc]==key){
        highLoc++;
    } 
    
    if (points[highLoc]>key){
        highLoc=highLoc-1;
    } 
    
    /* Create matrix for the return argument. */
    plhs[0] = mxCreateDoubleMatrix(1, 2, mxREAL);
    ptr = mxGetPr(plhs[0]);
    ptr[0]=lowLoc;
    ptr[1]=highLoc;
}