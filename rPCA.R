#rPCA for outlier removal prior to SVA
library('rrcov')
library("DESeq2")
library('ggplot2')

mdata <- read.csv("RNAseq_metadata_11-30-20.csv", header=T) # read in expression data
rownames(mdata) <- mdata[,1] ; mdata[,1] <- NULL # reset rownames to Orthogroup columns
pheno <- read.csv("factors_v1.csv", header=T) # read in phenotype data
rownames(pheno) <- pheno[,2]
head(mdata[,1:5]) ; head(pheno)
pheno2<-pheno[colnames(mdata),]

#NORMALIZATION
vstdata<-varianceStabilizingTransformation(round(as.matrix(mdata+1)), blind = TRUE, fitType = "parametric")

saveRDS(vstdata,'vstdata.rds')

#######################     First method PcaGrid  ###############################
rob_pca<-PcaGrid(t(vstdata),k=5)
saveRDS(rob_pca,'rob_pca.rds')


#Indicator of outliers: FALSE for outlier, TRUE for regular sample
outliers<-rob_pca@flag
outlier_sras <- outliers[which(outliers==FALSE)] #extract outliers from rob_pca
outlier_sras <- data.frame(outlier_sras) #data frame of outlier SRA accessions
head(outlier_sras)

#how many outliers?
length(which(outliers=='FALSE'))

#rPCA plots
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$tissue), main = "Tissue")
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$stress), main = "Stress")
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$family), main = "Family")


##Visualization

pheno3<-data.frame(pheno2,robust_score_distance=rob_pca@sd,orthogonal_distance=rob_pca@od)

#Outlier plot with cut.off values
p <- ggplot(data=pheno3, aes(x=robust_score_distance, y=orthogonal_distance)) + geom_point()
p<-p+xlim(0, 5)+ylim(0,400)
p<-p + geom_hline(yintercept=rob_pca@cutoff.od, linetype="dashed", color = "red")+geom_vline(xintercept =rob_pca@cutoff.sd,color = "blue")

pdf("outlier_plot_pcaGRID_K=5.pdf")
p
dev.off()

#Outlier plot colored by family
p1<-ggplot(data=pheno3, aes(x=robust_score_distance, y=orthogonal_distance,color=family)) + 
  geom_point()
p1<-p1+xlim(0, 5)+ylim(0,400)
p1<-p1 + geom_hline(yintercept=rob_pca@cutoff.od)+geom_vline(xintercept =rob_pca@cutoff.sd)

pdf("outlier_plot_pcaGRID_K=5_family.pdf")
p1
dev.off()

#Outlier plot colored by stress

p1<-ggplot(data=pheno3, aes(x=robust_score_distance, y=orthogonal_distance,color=stress)) + 
  geom_point()
p1<-p1+xlim(0, 5)+ylim(0,400)
p1<-p1 + geom_hline(yintercept=rob_pca@cutoff.od)+geom_vline(xintercept =rob_pca@cutoff.sd)

pdf("outlier_plot_pcaGRID_K=5_stress.pdf")
p1
dev.off()

#Outlier plot colored by tissue

p1<-ggplot(data=pheno3, aes(x=robust_score_distance, y=orthogonal_distance,color=tissue)) + 
  geom_point()
p1<-p1+xlim(0, 5)+ylim(0,400)
p1<-p1 + geom_hline(yintercept=rob_pca@cutoff.od)+geom_vline(xintercept =rob_pca@cutoff.sd)

pdf("outlier_plot_pcaGRID_K=5_tissue.pdf")
p1
dev.off()

#Outlier plot colored by species

p1<-ggplot(data=pheno3, aes(x=robust_score_distance, y=orthogonal_distance,color=species)) + 
  geom_point()
p1<-p1+xlim(0, 5)+ylim(0,400)
p1<-p1 + geom_hline(yintercept=rob_pca@cutoff.od)+geom_vline(xintercept =rob_pca@cutoff.sd)
p1<-p1+theme_bw()+geom_text(aes(label=ifelse(orthogonal_distance>230,as.character(species),'')),hjust=0, vjust=0)+theme(legend.position = "none")

pdf("outlier_plot_pcaGRID_K=5_species2.pdf")
p1
dev.off()

####################### PcaGrid Method: No normalization #######################
saveRDS(t(mdata),'tmdata.rds')

model <- lm(t(mdata) ~ tissue + stress + family, data = pheno2)
#Linearity of data
plot(model$fitted.values, model$residuals, main = "Residuals vs Fitted")

rob_pca<-PcaGrid(t(mdata),k=5)
saveRDS(rob_pca,'rob_pca.rds')

#Indicator of outliers: FALSE for outlier, TRUE for regular sample
outliers<-rob_pca@flag
outlier_sras <- outliers[which(outliers==FALSE)] 
outlier_sras <- data.frame(outlier_sras)
head(outlier_sras)

#how many outliers?
length(which(outliers=='FALSE'))

#rPCA plots
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$tissue), main = "Tissue")
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$stress), main = "Stress")
plot(rob_pca$scores[,1], rob_pca$scores[,2], col = as.factor(pheno2$family), main = "Family")




###############     Second method PcaHubert ###############################
 
#hu_pca<-PcaHubert(t(vstdata),k=5,kmax=5)
#saveRDS(hu_pca,'hu_pca.rds')

#Indicator of outliers: FALSE for outlier, TRUE for regular sample
#outliers<-hu_pca@flag

#how many outliers?
#length(which(outliers=='FALSE'))

