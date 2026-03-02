I started out by looking at previous lecture repos to make sure I had a good directory structure. 

I added the dataset (train.csv) to my data/raw folder. I played around with the dataset and visualized it. I made a histogram of shares and saw that it was right skewed, with a long right tail. I looked at the summary of the data and saw that the mean/median/1Q/3Q were all within 3000 of each other, but the max was over 800000. Because of this, i decided to take the log of shares, like in the lecture 10 repo.


I then decided to start from scratch with the src files. 
Config file: 
I asked Gemini to explain what was going on with the code in the lecture 10 configure file. From its explanaion I gathered that the capitalized code is acting as a constant, defining things now so that the programmer can use the constant later, rather than having to fully type things out each time. I set the seed to a random number. I asked Gemini how I can best ensure reproducibility and it suggested I use the "here" package, which, rather than manually moving R to different folders, sets the project root as the starting point for every file path within the project. It uses the Rproj folder as its home base. The reason I chose to use this was a) it was more intuitive for me to understand, and b) if I moved folders around, the here function would still work. I initially chose to use lasso, but later moved to ridge, because I was worried about a higher MSE with lasso (lasso might throw away certain variables, but ridge keeps all of them). 

 I chose to stick with a range of -5 to 5 for the ridge penalty range and set levels to 50 to try and find the best penalty. 

 Setup folder: Again, I asked Gemini to explain the strucutre of the lecture 10 setup folder, and then installed any missing packages. 


Data cleaning/split: I looked at the code from lecture 10 and saw that you dropped the url variable since it doesnt add anything, and changes shares to log because of the distribution. I chose to do that as well. I followed the logic of lecture 10 to create a function to clean data, and then create a script to split it. As I typed, the cursor ai offered some code that i accepted, such as n <- nrow(all_data_cleaned)
train_index <- sample(1:n, size = floor(DATA_SPLIT * n))


Before testing which model was best, I had to choose my variables. I initially chose lasso, and then later when changing to ridge, decided to keep the nested CV anyway, because I already had the code and wanted to ensure rigor. I looked the code from lecture 10 and asked gemini to explain what the code was doing, line by line, especially the @ parts (which I learned describes essential variables in the code). As I wrote the practice/final codes and worked with Gemini, I forgot I had the nested CV functions written. Still kept the src file.  


I made a practice model based on splitting train.csv into a train and test split. I chose to include some interaction terms (initially included several such as is_weekendxdata_channel_is_lifestyle, and weekday_is_mondayxtitle_sentiment_polarity, based on what I assumed people would find interesting at different times during the week). I checked the coefficients on many of these interaction terms and saw that they were very small (eg,weekday_is_friday_x_data_channel_is_socmed  = 0.00583) - I figured these only increased my MSE, so I chose not to include them in my model. I also thought that the kwd_avg_avg might have a nonlinear effect (Gemini explained that this variable is the average number of shares for the average keyword in the story), but when I squared it, MSE increased, so I chose not to include it. I asked Gemini to help me check my work and it pointed out that I was missing doing nested cv - it was performing like standard CV because I had forgotten to perform the nested cv loop. I asked it to help me code the loop, and I accepted its suggestions. 

With guidance from lecture 10, as well as interpretation assistance from Gemini when I didn't understand what certain code was doing, I created the practice model. As above, Cursor's Ai would suggest code which was similar to lecture 10/it seemed to achieve the goal I was looking for, so I accepted it. I got an MSE of 78346012 on my practice model, meaning a root mean squared error of roughly 8000 shares. 

The writing of the final model code was similar - as in lecture 10, I saved it as an RDS (Gemini explained to me what the purpose of saving it was: to avoid having to rerun it every time).

Evaluation: I asked Gemini how to ensure that nothing expect the MSE printed, and it told me to use the suppressMessages code, which I used. Also, I asked it about other ways I could ensure my MSE was as low as possible, and it suggested using the Smearing Factor, which accounts for any changes due to taking the log of the target variable. Instead of hardcoding a particular number, I asked Gemini to help me write code to have the computer calculate the Smearing Factor itself, to avoid overfitting it to this particular sample.  

I spent several hours playing around with different interaction terms and variables. When I tested the final model on the train.csv (renamed as test.csv so that I could practice "make evaluate"), I continuously received MSEs of 128-131million. The final interaction terms included reflect the ones that allowed me to achieve the lowest MSE. 

As I finished each section, I asked Gemini whether there were any inefficiencies in the code. 
