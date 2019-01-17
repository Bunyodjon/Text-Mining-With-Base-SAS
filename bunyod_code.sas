/*
Discription of the program: This script does three tasks: 
1) Scraps two speechs from a public website 
2) Creates a spider plot with 10 Emotions grouped by president
3) Creates Time Series plot with Sentiment score grouped by president
Date: November 01, 2018
Last Updated: December 18, 2018 
Author: Bunyod Tusmatov 
Input Data Sets: two text data sets   
Output variable: two plots and two text files 

/* ============================== Web Scraping ============================== */

/* Donald Trump Speech */
filename src temp;
/* scrap whole http source code from the website */
proc http
 method="GET"
 url="https://www.presidency.ucsb.edu/documents/address-before-joint-session-the-congress-2"
 out=src;
run;

data trump;
infile src length=len lrecl=32767;
input line $varying32767. len;
 line = strip(line);
 if len>0;
run;

data trump2; 
	set trump(firstobs=190 obs=274);
run;

* we need to remove </p>,  <p>,  [<i>Laughter</i>]  [<i>Applause</i>]  ;
data trump3;
  set trump2;
  line = TRANWRD(line,"<p>","");
  line = TRANWRD(line,"</p>","");
  line = TRANWRD(line,"[<i>Laughter</i>]","");
  line = TRANWRD(line,"[<i>Applause</i>]","");
run;

proc print data=trump3;
run;

/* Barack Obama Speech 2009 */
filename src temp;
proc http
 method="GET"
 url="https://www.presidency.ucsb.edu/documents/address-before-joint-session-the-congress-1"
 out=src;
run;

data obama;
infile src length=len lrecl=32767;
input line $varying32767. len;
 line = strip(line);
 if len>0;
run;

data obama2; 
	set obama(firstobs=190 obs=264);
run;

* we need to remove </p>,  <p>,  [<i>Laughter</i>]  [<i>Applause</i>]  ;

data obama3;
  set obama2;
  line = TRANWRD(line,"<p>","");
  line = TRANWRD(line,"</p>","");
  line = TRANWRD(line,"[<i>Laughter</i>]","");
  line = TRANWRD(line,"[<i>Applause</i>]","");
run;

proc print data=obama3;
run;

/* ============================== Sentiment Analysis ========================= */

/* import president Donald Trump 2017 State Of the Union (SOTU) address */
data sotu_trump2017;
	length word $ 10;
  	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\sotu_trump2017.txt' dlm=' ' dsd;
  	input word $ @@;
run;

data sotu_trump2017;
  set sotu_trump2017;
  word = TRANWRD(word,".","");   * remove period from any word;
  word = TRANWRD(word,",","");   * remove comma from any word;
  word = TRANWRD(word,"!","");   * remove ! from any word;
  word = TRANWRD(word,"?","");   * remove ? from any word;
  word = TRANWRD(word,"_","");   * remove _ from any word;
  word = TRANWRD(word,"(","");   * remove ( from any word;
  word = TRANWRD(word,")","");   * remove ) from any word;
  word = TRANWRD(word,";","");   * remove *;* from any word;
  word = TRANWRD(word,":","");   * remove *:* from any word;
  word = COMPRESS(word, "1234567890+-$[]{}");
  word = COMPRESS(word, "/");
  word = TRANWRD(word,"â€”"," "); * replace special characters in word with space;
  word = TRANWRD(word,"â§","");
  word = TRANWRD(word,"â€","");
  word = LOWCASE(word);          * convert all letters to lowercase;
  if missing(cats(of _all_)) then delete;
run;

proc print data=sotu_trump2017;
run;

/* import president Barack Obama 2009 State Of the Union (SOTU) address */
data sotu_obama2009;
	length word $ 10;
  	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\sotu_obama2009.txt' dlm=' ' dsd;
  	input word $ @@;
run;

data sotu_obama2009;
  set sotu_obama2009;
  word = TRANWRD(word,".","");   * remove period from any word;
  word = TRANWRD(word,",","");   * remove comma from any word;
  word = TRANWRD(word,"!","");   * remove ! from any word;
  word = TRANWRD(word,"?","");   * remove ? from any word;
  word = TRANWRD(word,"_","");   * remove _ from any word;
  word = TRANWRD(word,"(","");   * remove ( from any word;
  word = TRANWRD(word,")","");   * remove ) from any word;
  word = TRANWRD(word,";","");   * remove *;* from any word;
  word = TRANWRD(word,":","");   * remove *:* from any word;
  word = COMPRESS(word, "1234567890+-$[]{}");
  word = COMPRESS(word, "/");
  word = TRANWRD(word,"â€”"," "); * replace special characters in word with space;
  word = TRANWRD(word,"â§","");
  word = TRANWRD(word,"â€","");
  word = LOWCASE(word);          * convert all letters to lowercase;
  if missing(cats(of _all_)) then delete;
run;

proc print data=sotu_obama2009;
run;
/* import stopwords SMART */
data work.stopwords;
	length word $ 10;
	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\stopwords.csv' dlm=',' firstobs=2;
	input word $;
run;
/* clean stopwords */
data stopwords;
  set stopwords;
  word = TRANWRD(word,'"',"");   * remove " period from stopwords;
  word = STRIP(word);
run;

proc print data=Stopwords;
run;

/* sort both stopwords and both speeches */ 
proc sort data=sotu_trump2017; 
   by word;
run;

proc sort data=sotu_obama2009; 
   by word;
run;

proc sort data=stopwords; 
   by word;
run;

/* remove stopwords from trump2017 speech */
data trump;
  merge sotu_trump2017 (in=inP) stopwords (in=inS);
  by word;
  if inP=1 and inS=0;
run;

/* remove stopwords from obama2009 speech */
data obama;
  merge sotu_obama2009 (in=inP) stopwords (in=inS);
  by word;
  if inP=1 and inS=0;
run;


ods rtf file="&dir\&subdir\ch7-fig7.1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=trump;
run;
ods rtf close;


/* create a sentiment column with nrc sentiment */ 

/* upload and clean up nrc data */
data work.nrc;
	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\nrc.csv' dlm=',' firstobs=2;
	input word $ sentiment $;
run;

data nrc;
  set nrc;
  word = TRANWRD(word,'"',"");   * remove " period from stopwords;
  sentiment = TRANWRD(sentiment,'"',"");
  word = STRIP(word);
  sentiment = STRIP(sentiment);
run;

/* merge ncr with president trump speech */ 
data sentiment1;
  merge trump (in=inP) nrc (in=inS);
  by word;
  if inP=1 and inS=1;
run;

/* merge ncr with president obama speech */ 
data sentiment2;
  merge obama (in=inP) nrc (in=inS);
  by word;
  if inP=1 and inS=1;
run;

* count sentiment frequency for Trump ;
proc freq data=sentiment1;
  table sentiment / out=sen_freq1;
  table word / out=wordfreq1;
run;

* count sentiment frequency for Obama ;
proc freq data=sentiment2;
  table sentiment / out=sen_freq2;
  table word / out=wordfreq2;
run;

data sen_freq1;
	set sen_freq1;
	name="Donald Trump 2017";
run;

data sen_freq2;
	set sen_freq2;
	name="Barack Obama 2009";
run;
* combine two data sets for the spider graph;
data sen_freq;
	set sen_freq1 sen_freq2;
run;

* spider diagram ;
goptions reset=all;
proc gradar data=sen_freq;
    chart sentiment / freq=COUNT overlayvar=name;
run;
quit;



/* ========================================================================= */
/*                                 Line Plot                                 */
/* ========================================================================= */

* we will use afinn lexicon for this part; 
data work.afinn;
	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\afinn.csv' dlm=',' firstobs=2;
	input word $ score;
run;
* clean up afinn lexicon ;
data afinn;
  set afinn;
  word = TRANWRD(word,'"',"");   * remove " period from stopwords;
  word = STRIP(word);
run;

* uplaod president Trump's speech and count words ;
data sotu_trump2017;
	retain line 0;
	length word $ 10;
	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\sotu_trump2017.txt' dlm=' ' dsd;
  	input word $ @@;
	line+1;
run;

* uplaod president Obama's speech and count words ;
data sotu_obama2009;
	retain line 0;
	length word $ 10;
	infile 'C:\Users\Admin\Documents\All Miami Courses\Fall 2018 Courses\Independent Study\data\sotu_obama2009.txt' dlm=' ' dsd;
  	input word $ @@;
	line+1;
run;


data sotu_trump2017;
  set sotu_trump2017;
  word = TRANWRD(word,".","");   * remove period from any word;
  word = TRANWRD(word,",","");   * remove comma from any word;
  word = TRANWRD(word,"!","");   * remove ! from any word;
  word = TRANWRD(word,"?","");   * remove ? from any word;
  word = TRANWRD(word,"_","");   * remove _ from any word;
  word = TRANWRD(word,"(","");   * remove ( from any word;
  word = TRANWRD(word,")","");   * remove ) from any word;
  word = TRANWRD(word,";","");   * remove *;* from any word;
  word = TRANWRD(word,":","");   * remove *:* from any word;
  word = COMPRESS(word, "1234567890+-$[]{}");
  word = COMPRESS(word, "/");
  word = TRANWRD(word,"â€”"," "); * replace special characters in word with space;
  word = TRANWRD(word,"â§","");
  word = TRANWRD(word,"â€","");
  word = LOWCASE(word);          * convert all letters to lowercase;
  if missing(cats(of _all_)) then delete;
run;
* Barack Obama;
data sotu_obama2009;
  set sotu_obama2009;
  word = TRANWRD(word,".","");   * remove period from any word;
  word = TRANWRD(word,",","");   * remove comma from any word;
  word = TRANWRD(word,"!","");   * remove ! from any word;
  word = TRANWRD(word,"?","");   * remove ? from any word;
  word = TRANWRD(word,"_","");   * remove _ from any word;
  word = TRANWRD(word,"(","");   * remove ( from any word;
  word = TRANWRD(word,")","");   * remove ) from any word;
  word = TRANWRD(word,";","");   * remove *;* from any word;
  word = TRANWRD(word,":","");   * remove *:* from any word;
  word = COMPRESS(word, "1234567890+-$[]{}");
  word = COMPRESS(word, "/");
  word = TRANWRD(word,"â€”"," "); * replace special characters in word with space;
  word = TRANWRD(word,"â§","");
  word = TRANWRD(word,"â€","");
  word = LOWCASE(word);          * convert all letters to lowercase;
  if missing(cats(of _all_)) then delete;
run;

/* sort both stopwords and both speeches */ 
proc sort data=sotu_trump2017; 
   by word;
run;

proc sort data=sotu_obama2009; 
   by word;
run;
 
proc sort data=afinn; 
   by word;
run;

* merge speech with afinn lexicon; 
data trump1;
  merge sotu_trump2017 (in=inP) afinn (in=inS);
  by word;
  if inP=1 and inS=1;
run;

* merge speech with afinn lexicon; 
data obama1;
  merge sotu_obama2009 (in=inP) afinn (in=inS);
  by word;
  if inP=1 and inS=1;
run;

* sort by line for the graph ; 
proc sort data=trump1; 
   by line;
run;

proc sort data=obama1; 
   by line;
run;

* Calculate moving average ; 
proc expand data=trump1 out=mov_ave;
	convert score=mov_ave4 / transout=(movave 4);
run;

/* red curve uses loess method for smoothing and blue curve is moving average
please feel free to choose one */

ods graphics / reset width=1000px height=480;
title "Sentiment Score throughout the speech";
proc sgplot data=mov_ave;
   scatter x=line y=score / markerattrs=(color=gray90); 
   series x=line y=mov_ave4 /lineattrs=(color=blue thickness=2);
   loess x = line y = score/nomarkers lineattrs=(color=red);
   yaxis label="Sentiment Score" grid;
   xaxis label="Lines";
run;


/* Combine data sets and plot both speeches on the same graph */ 

data trump1; 
	set trump1;
	president="Donald Trump 2017";   *create new variable for grouping;
run;

data obama1;
	set obama1;
	president="Barack Obama 2009";   *create new variable for grouping;
run;
/* stack (rbind) two data sets */ 
data all_data;
	set trump1 obama1;
run;

/* plot the graph */
ods graphics / reset attrpriority=color width=1000px height=480;
title 'Sentiment Score Comparison';
proc sgplot data=all_data;
  loess x = line y = score/group=president nomarkers;
  scatter x=line y=score / transparency=0.5 group=president;
  yaxis label="Sentiment Score" grid;
  xaxis label="Lines";
run;
