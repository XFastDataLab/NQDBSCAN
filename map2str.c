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
#include "string.h"
#include "stdio.h"
#include "stdlib.h"

typedef struct _node{
    char *name;
	int index;
    int num;
    struct _node *next;
}node;

#define HASHSIZE 100000000
static node* hashtab[HASHSIZE];

void inithashtab(){
    int i;
    for(i=0;i<HASHSIZE;i++)
        hashtab[i]=NULL;
}

unsigned int hash(char *s){
    unsigned int h=0;
    for(;*s;s++)
        h=*s+h*31;
    return h%HASHSIZE;
}

node* lookup(char *n){
    unsigned int hi=hash(n);
    node* np=hashtab[hi];
    for(;np!=NULL;np=np->next){
        if(!strcmp(np->name,n))
            return np;
    }
    
    return NULL;
}

char* m_strdup(char *o){
    int l=strlen(o)+1;
    char *ns=(char*)malloc(l*sizeof(char));
    strcpy(ns,o);
    if(ns==NULL)
        return NULL;
    else
        return ns;
}

int getIndex(char* name){
    node* n=lookup(name);
    if(n==NULL)
        return -1;
    else
        return n->index;
}

int getNum(char* name){
    node* n=lookup(name);
    if(n==NULL)
        return -1;
    else
        return n->num;
}

int install(char* name, int num, int index){
    unsigned int hi;
    node* np;
    if((np=lookup(name))==NULL){
        hi=hash(name);
        np=(node*)malloc(sizeof(node));
        if(np==NULL)
            return 0;
        np->name=m_strdup(name);
        if(np->name==NULL) return 0;
        np->next=hashtab[hi];
        hashtab[hi]=np;
    }
    np->num=num;
	np->index=index;
    
    return 1;
}

/* 
 * A pretty useless but good debugging function,
 * which simply displays the hashtable in (key.value) pairs
 */
void displaytable(){
    int i;
    node *t;
    for(i=0;i<HASHSIZE;i++){
        if(hashtab[i]==NULL)
            printf("()");
        else{
            t=hashtab[i];
            printf("(");
            for(;t!=NULL;t=t->next)
                printf("(%s.%d) ",t->name,t->num);
            printf(".)");
        }
    }
}

void cleanup(){
    int i;
    node *np,*t;
    for(i=0;i<HASHSIZE;i++){
        if(hashtab[i]!=NULL){
            np=hashtab[i];
            while(np!=NULL){
                t=np->next;
                free(np->name);
                //free(np->num);
                free(np);
                np=t;
            }
        }
    }
}


/*
 *
 *input: a matrix 'points'
 *output:
 *      1) plhr[0]:a unique array of string mapped from points.
 *         For example [1 2 3;1 2 3; 3 2 1]-> 'id#1#2#3; id#3#2#1'
 *      2) plhr[1]:a vector 'gridIndex' that saves the grid index to which each point belongs 
 *         For example, if gridIndex[i]=2 means the i^th point included in the 2nd grid.
 *      3) plhr[2]: the matrix of the mapped coordinates of each unique non-empty grid.
 *      4) plhr[3]: A cell that save all points that contained by each grid.
 *         e.g. cell{i}=[1,2,3] means the i^th grid includes point 1,2 and 3 .
 *      5) plhr[4]: the number of the non-empty grids.
 *      6) plhr[5]: the number of points in each grid.
 */ 
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] )
{       
    int mrows,ncols,i,j,val,pos,nonEmptyGridCounter,index;
    double *points;
    size_t buflen;
    
    //gridIndex saves the grid index of each point belongs to 
    //gridStrings save the unique mapped strings
    //nonEmptyGrids save the uniuqe vectors in points
    mxArray *gridIndex,*gridStrings, *nonEmptyGrids,*pointsInGridsCell;

    mxArray* pmxTr;
    mxArray* cellPtr;
            
    double *gridIndexPtr,*nonEmptyGridsPtr;
    int* recorder, *uniqueLoc;
	double *doubleArrPtr;
    
    char** gridStrMatrix;
    char* gridStr;
    char tmpSep[100];
    char tmpBuf[100];
    char tmpCom[1];

    strcpy(tmpSep,"");
    strcpy(tmpBuf,"");
	strcat(tmpSep,"#");
            
    /* The input must be a noncomplex scalar double.*/
    //mrows is the rows of input matrix
    mrows = mxGetM(prhs[0]);    
    //nclos is the collumns of input matrix
    ncols = mxGetN(prhs[0]);
    
    //input matrix
    points = mxGetPr(prhs[0]); 
    
    //allocate memeory
    gridStr=mxCalloc(ncols*10, sizeof(char));
    gridStrMatrix=(char **)malloc(sizeof(char *)*mrows);
    for (i=0; i<mrows; i++){
        gridStrMatrix[i]=(char *)malloc(ncols*10*sizeof(char));
    }
    
    //save the grid index of each point belongs to 
    gridIndex=mxCreateDoubleMatrix(1, mrows, mxREAL); 
    //the pointer of gridIndex
    gridIndexPtr = mxGetPr(gridIndex);
    
    //count the unique grids found
    nonEmptyGridCounter=0;
    
    //initiate a hash table
    inithashtab();
    uniqueLoc=(int*)malloc(sizeof(int)*mrows);
    for (i=0; i<mrows;i++){
        strcpy(gridStr,"");
        for (j=0; j<ncols;j++){
			//val=point[i][j];
            val= *(points+j* mrows+i); 
			itoa(val,tmpBuf,10);
			//add a '#'
            strcat(gridStr,tmpSep);
            strcat(gridStr,tmpBuf);   
        }    		
   
        pos=getNum(gridStr);
        
        //pos==-1 means the grid appears in the first time
        if (pos==-1){
            //save the first point appears in the nonEmptyGridCounter^th grid
            uniqueLoc[nonEmptyGridCounter]=i;
            nonEmptyGridCounter++;    

            //add into the hash table
            install(gridStr,1,nonEmptyGridCounter);
            
            //save the grid index for i^th point 
            gridIndexPtr[i]=nonEmptyGridCounter;   
            strcpy(gridStrMatrix[nonEmptyGridCounter-1],gridStr);

			pos=getNum((char*)gridStrMatrix[nonEmptyGridCounter-1]);
        }else {            
            pos++;
            //update the number of points of gridStr
            index=getIndex(gridStr);
            install(gridStr,pos,index);
            //save the grid index for i^th point 
            gridIndexPtr[i]=index;
        }            
    }    


    //create a cell to save unique  strings mapped from points
    gridStrings = mxCreateCellMatrix(1,nonEmptyGridCounter);     
    //create a matrix to save the unique grids
    nonEmptyGrids=mxCreateDoubleMatrix( nonEmptyGridCounter,ncols, mxREAL);
    //pointer of nonEmptyGrids
    nonEmptyGridsPtr = mxGetPr(nonEmptyGrids);
    
    //pointsInGridsCell is a cell that save all points for each grid, 
    //e.g. cell{i} =[1,2 3] means the 1st grid has 3 members [point1, point2 and point3]
    pointsInGridsCell = mxCreateCellMatrix( 1,nonEmptyGridCounter);
    for (i=0; i<nonEmptyGridCounter;i++){		 
		gridStr= (char*)gridStrMatrix[i];
		
		pos=getNum(gridStr);

		pmxTr=mxCreateDoubleMatrix(1,pos, mxREAL);
		for (j=0;j<pos;j++){
			mxGetPr(pmxTr)[j]=0;
		}
		//save points in each cell
		mxSetCell(pointsInGridsCell, i, pmxTr);    

		//save grid mapped string
		mxSetCell(gridStrings, i, mxCreateString(gridStr));
  
		//assign non-empty grid's coordinates
		for (j=0; j<ncols;j++){
			val= *(points+j* mrows+uniqueLoc[i]);
			//save the grid 
			*(nonEmptyGridsPtr+j* nonEmptyGridCounter+i)=val;
		} 
    }
    
    //return values
    //the mapped strings
    plhs[0] = gridStrings;
    //the grid index for each point
    plhs[1] = gridIndex;
    //the unique grids found
    plhs[2] = nonEmptyGrids;
   
    //return a cell that save all points of each grid, 
    //e.g. cell{i} =[1,2 3] means the 1st grid has 3 members [point1, point2 and point3]
    plhs[3]=pointsInGridsCell;
            
    //recorder is used to record the number of scaned points for each grid
    //e.g. recorder[i]=2 means there are 2 scanned points for the 2nd grid.
    recorder=(int*)malloc(nonEmptyGridCounter*sizeof(int));  
    //initialize recorder
    for (i=0; i<nonEmptyGridCounter;i++){
        recorder[i]=0;
    }
        
    for (i=0; i<mrows;i++){   
        gridIndexPtr = mxGetPr(gridIndex);
        //the start pos is 0 in C 
        index= gridIndexPtr[i]-1;
        gridStr= (char*)gridStrMatrix[index];
        
        //calculate the number of points in each cell
        cellPtr=mxGetCell(plhs[3],index);
        doubleArrPtr=(double*)mxGetData(cellPtr);
        //the start pos is 1 in matlab
        doubleArrPtr[recorder[index]]=i+1;
        
        recorder[index]++;        
    }
    
    //the number of the non-empty grids
    plhs[4] = mxCreateDoubleMatrix( 1,1, mxREAL);
    gridIndexPtr = mxGetPr(plhs[4]);
    *gridIndexPtr=nonEmptyGridCounter;
    
    //the number of points in each grids
    plhs[5] = mxCreateDoubleMatrix( 1,nonEmptyGridCounter, mxREAL);
    for (i=0; i<nonEmptyGridCounter;i++){   
        mxGetPr(plhs[5])[i]=recorder[i];
    } 
    
    //clean memeory
    for (i=0; i<mrows;i++){
         gridStr= (char*)gridStrMatrix[i];
         free(gridStr);
    }
    free(gridStrMatrix);
    free(recorder);
    
    //clear the hash table
    cleanup();    
}