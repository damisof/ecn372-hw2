

all:
	Rscript scripts/split_data.R
	Rscript scripts/practicemodel.R
	Rscript scripts/finalmodel.R
	Rscript scripts/evaluate.R

model:
	Rscript scripts/finalmodel.R


data:
	Rscript scripts/split_data.R


evaluate:
	Rscript scripts/evaluate.R
	

