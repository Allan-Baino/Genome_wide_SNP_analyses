#'---
#'author: Allan Baino
#'date: 2nd Jan, 2025
#'title: Popn genetics analyses for African giant pouched rat SNP data 
#'---

#'
#'###Background
#'**Biological samples from African giant pouched rats collected were collected
#'from Tanzania. Samples were subjected to genomic DNA extraction and prepared 
#'for paired-end sequencing - ddRAD on a NovaSeq X series system. Reads were
#'aligned to a pouched rat ref. 🧬 (GCA_026225945.1) to call and catalog variant
#'sites (SNPs). SNPs were then converted to file formats compatible with R to perform
#'pop gen analyses. 
#'---
#' 

#'###Research objectives
#'**) To delineate population structure for populations of African giant pouched 
#'rats in Tanzania**
#'**2) To detect signals of genetic differentiation for captive African giant 
#'pouched rats in Tanzania**
#'**3) To elucidate genetic diversity for populations of African giant pouched 
#'rats in Tanzania**
#'---
#'

#'load libraries
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggfortify))
suppressPackageStartupMessages(library(lme4))
suppressPackageStartupMessages(library(adegenet))
suppressPackageStartupMessages(library(hierfstat))
suppressPackageStartupMessages(library(vegan))
suppressPackageStartupMessages(library(psych))
suppressPackageStartupMessages(library(devtools))
suppressPackageStartupMessages(library(BiocManager)) #the BiocMangr is needed to install qvalue, a package called by OutFLANK
suppressPackageStartupMessages(library(OutFLANK))
suppressPackageStartupMessages(library(pcadapt))
suppressPackageStartupMessages(library(qvalue))
suppressPackageStartupMessages(library(ggbiplot))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(grid))
suppressPackageStartupMessages(library(RefManageR))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(pegas))
suppressPackageStartupMessages(library(vcfR))
suppressPackageStartupMessages(library(assignPOP))

#'population structure
#'input .str file, 

#' import .str file PR_SNPs80.str with read.structure function embedded in 
#' 📦 adegenet
pr80 <- read.structure("PR_SNPs80.str", 
                       n.ind=93, 
                       n.loc = 2762,
                       onerowperind = FALSE, 
                       col.lab = 1, 
                       col.pop = 2,    
                       row.marknames = 0, 
                       NA.char = "-9",
                       ask=FALSE)
#'parameters: n.ind=sample size, n.loc=n# loci, onerowperind=F (nrow≠samples),
#'col.lab=1 (sampleID), col.lab=2 (popID), row.marknames=0 (no marker names),
#'ask=F (because all information has been provided).
#'---
#'

#'check data structure of genind object to see if data imported ✅ 
pr80

#'individuals that were not successfully genotyped were eliminated as they don't
#'provide useful information for downstream analyses. Severe reductions in data 
#'could mean you have less confidence in your biological assertions however,
#'in this instance retained data seems adequate...sample size dropped from 93 to
#'84 individuals..you can also get a detailed summary of the genind objects...
#'summary(pr80).
#'---
#'
summary(pr80)

#'lets now convert our genind object into a hierfstat object to perform a basic 
#'PCA analysis
pr80.hfstat <- genind2hierfstat(pr80)

#'check data structure
str(pr80.hfstat)

#'compute PCA
x80 <- indpca(pr80.hfstat, pr80.hfstat$pop)

#'visualize components that explain the most variance PCA objects, usually first
#'few components explain most of the variation. good practice is to consider those 
#'that explain largest proportion of variance.
var_exp80 <- (x80$ipca$eig / sum(x80$ipca$eig)) * 100

#'you can call the objects to view percent variance explained by PCs
var_exp80

#'or you can do screeplots, much better visuals
bp80 <- barplot(var_exp80[1:15], main = "Screeplot pouched rats PCA80",
              ylab = "% variance explained", 
              xlab = "principal components",
              col="#69b3a2")

#'alternatively we can use ggscreeplot
ggscreeplot(x80$ipca)+
  theme_bw()+
  labs(x="Principal components", y="Proportion of explained variance")+
  ylim(c(0,1))

#'lets now generate two-dimensional plots for each of the SNPs data set to see
#'how many genetic clusters are delineated.
#'x80
ggplot(x80$ipca$li, aes(x=Axis1, y=Axis2, color = pr80.hfstat$pop)) + 
  geom_point() +
  scale_x_continuous(name="PC 1") +
  scale_y_continuous(name="PC 2") +
  scale_color_discrete(name="sampled populations") +
  theme_bw()

#'based on the plot its likely that we have distinct genetic clusters (n# of 
#'genetic populations) across sampling range with structuring and some admixture
#'however, this is preliminary and a further dive is required.

#'lets now estimate population structure using DAPC - discriminant analysis of 
#'principal components to find population clusters that best describe our data 
#'set.

#'use find.clusters function in 📦 adegenet
gp80 <- find.clusters(pr80, max.n.clust = 20)

#'selection of optimal genetic clusters/populations should be based on n# of PCs
#'that explain the most variance and minimize BIC. if decrease in BIC is gradual
#'optimal cluster selection is based on largest BIC value drop compared to other
#'clusters, this is considered the "most appropriate" solution..3 PCs were 
#'retained and 4 clusters (largest BIC drop) were selected.

#'we can now create a table to see how individuals are assigned to the different 
#'groups.  
pop_table <-table(pop(pr80), gp80$grp)
write.csv(pop_table, "poptable.csv", row.names = T)

#'we can now perform a DAPC analysis  
dapc80 <- dapc(pr80, gp80$grp)

#'parameters: n.pca (PCs) retained = 3 and n.da (discriminant functions) retained
#'= 3, based on % of variance exp. by PCs lines 109,110 and DAPC plot of eigen
#'values analysis.    
 
#'we can now plot our dapc object to visualize how population groups differ in 
#'multidimensional space.
scatter(dapc80)

#'we can also look at how each individual assigns to clusters. this is a good way
#'of understanding how strong the structuring is in your populations.
n_clusters <- length(unique(dapc80$grp))
compoplot(dapc80, posi="bottomright",txt.leg=paste("Cluster", 1:n_clusters),
          lab="",ncol=1, xlab="individuals", col=funky(n_clusters))
#'individuals assigned with high probability to their respective clusters, it is
#'likely we have arrived at a reasonable solution (distinct clusters with some 
#'admixture/shared ancestry) 

#'let's now export probability of membership for each individual, this will be 
#'useful downstream (mapping based on membership, quantifying strength of membership).
write.table(dapc80$posterior, "pr_80membership2.txt", quote = F)
#'at this juncture we can safely resolve that an initial analysis that only had 
#'1,988 SNPs vs. current with 2,762 SNPs yielded similar results however, variance
#'used to separate PCs did improve by a significant margin when using more SNPs,
#'essentially more information/loci is always good to have.

#'lets now venture into identifying SNPs that could be driving observed population 
#'structure. we can use information in the discriminant function model to identify
#'SNP loci that resolve the clusters by looking at the loadings for each SNP...
#'i.e. extract the contributions of original variables to the discriminant functions,
#'these contributions help identify which variables are most important in delineating
#'clusters.
l80 <- dapc80$var.contr
threshold <- quantile(l80, 0.98)
topSNPs <- names(l80[l80 > threshold])
#'display most important variables in the 98th percentile i.e. only variables 
#'with contributions in the top 2.0% will be displayed. 
loadingplot(l80, threshold = threshold, lab = topSNPs)

#'lets use top SNPs (alleles) info to create a subset data set for analysis with
#'just those SNPs, start by getting max contributions of top SNPs across all axes
max_cont <- apply(l80, 1, max)
threshold2 <- quantile(max_cont, 0.98)
topSNPs2 <- names(max_cont[max_cont > threshold2])
print(topSNPs2)
#'there are 108 SNPs/variables/alleles in the 98th percentile driving popn structure.

#'subset top 2% alleles from original data genind object (designing small SNP array)
pr80_sub <- pr80[, topSNPs2]
#'create a matrix for easy manipulation
pr80_sM <- as.matrix(pr80_sub)
print(pr80_sM)
#'convert all NAs to zero
pr80_sM[is.na(pr80_sM)] <- 0
#'for each individual, lets find out which top SNPs they carry
pres_mat <- pr80_sM > 0 
print(pres_mat)
#'identify indvs. that carry top SNPs and get summary stats. 
#'loop systematically goes through all the top SNPs and identifies the individuals
#'carrying each one.
for (snp in topSNPs) {
  carriers <- rownames(pres_mat)[pres_mat[, snp]]
  cat(paste("Individuals carrying SNP", snp, ":", paste(carriers, collapse = ", "), "\n"))
}
#'summary statistics, count of n# top SNPs (alleles) carried by each individual
snp_counts_per_individual <- rowSums(pres_mat)
print(snp_counts_per_individual)
write.csv(snp_counts_per_individual, "SNPs_individual.csv", row.names = T)
#'plot of top SNPs across samples by populations
SNPdata <- read.csv("SNPs_individual.csv", header = T)
#'check data
str(SNPdata)
#'make comparison group for t-test
comparisons <- list(c("popAPb", "popAPg"))
#'make sample counts
counts <- SNPdata %>%
  group_by(sample_location) %>%
  summarise(n = n(), max_y = max(allele_count))
#'plot
ggplot(SNPdata, aes(x = sample_location, y = allele_count, color = sample_location)) +
  geom_boxplot(width = 0.3) +
  geom_jitter(width = 0.1, size = 1, alpha = 0.4) +
  geom_text(data = counts, 
            aes(x = sample_location, 
                y = max_y + 5, 
                label = paste("n =", n)),
            color = "black", size = 3) +
  stat_compare_means(comparisons = comparisons, method = "t.test", label = "p") +
  theme_minimal() +
  labs(x = "sampling location", y = "allele count") +
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5),
        legend.position = "none")
#'we can also visualize this with a heat map to show presence-absence
pheatmap(pr80_sM, 
         cluster_rows = F, 
         cluster_cols = F,
         fontsize = 10,                
         fontsize_row = 8,             
         fontsize_col = 8,
         legend_breaks = c(0,1,2),
         fontsize_number = 4,
         )
#'Cross-validation of top SNPs to use as a proxy for popn assignment accuracy
#'lets subset the original data to retain meta data accurately
pr80_sub2 <- pr80
topSNPs2_c <- unique(sub("\\..*", "", topSNPs2))
colnames(pr80_sub2@tab) <- gsub("\\..*", "", colnames(pr80_sub2@tab))
valid_loci <- intersect(locNames(pr80_sub2), topSNPs2_c)
pr80_sub22 <- pr80_sub2[, loc = valid_loci]
#'rename loci to rid dapc from falsely interpreting alleles as duplicates
locNames(pr80_sub22) <- make.unique(locNames(pr80_sub22))
#'cluster for sub data
gp80_sub22 <-find.clusters(pr80_sub22, max.n.clust = 20)
#'perform DAPC
dapc80_sub <- dapc(pr80_sub22, gp80_sub22$grp)
#'perform cross-validation to assess DAPC accuracy
xval_result <- xvalDapc(
  tab(pr80_sub22, NA.method = "mean"),# genotype matrix, impute NAs by mean of @loc
  grp = gp80_sub22$grp,               # tell xvalDapc() how indvs are assigned to grps
  training.set = 0.9,                 # use 90% of data for training
  n.pca.max = 20,                     # maximum PCs to retain
  result = "groupMean",               # set discr. to mean position of each group
                                      # in PC space rather than indv. assign
  center = TRUE,
  scale = TRUE,
  n.rep = 30,                         # number of cross-validation replicates
  xval.plot = TRUE                    # plot the accuracy results
)
#'cross validation indicates assignment of individuals between 4 - 11 clusters/PCs. 
#'a trade-off has to be made btn under or over fitting and it is recommended to 
#'select the first fewest PCs that reduce assign. errors and provide the best 
#'prediction. if assign. accuracy is high then selected SNPs are effective in
#'distinguishing populations. 

#'cancelled this..attempt
#'Assignment accuracy analysis by cross-validation (k-fold/assignPOP)
#'extract population labels
populations <- pop(pr80)
# set the n# of folds for cross-validation (chosen a 10-fold cross-validation)
k_folds <- 10
#'

#'Outlier analysis/test for selection
#'read in .vcf file
prAD_vcf <- read.vcfR("cans_108inds_Pop_minDP6GQ5_0.80missing_maxmeanDP_biallelic_maf5%_LDpruned_TRrm.recode.vcf")
#'extract genotypes from .vcf files
prAD_gt <- extract.gt(prAD_vcf)
#'convert genotypes to numeric (0,1,2), keep NAs intact
prADgt_num <- apply(prAD_gt, 2, function(x) {
  # replace "0/0" with 0, "0/1" or "1/0" with 1, and "1/1" with 2
  x <- gsub("0/0", "0", x)
  x <- gsub("1/1", "2", x)
  x <- gsub("0/1|1/0", "1", x)
  as.numeric(x)
})
#'extract original row names from genotype matrix
row_names <- rownames(prAD_gt)
#'add them back to transformed matrix
rownames(prADgt_num) <- row_names
#'check conversion worked
head(prADgt_num)
#'save output (prevents you from repeating these steps when you exit R)
prAD_data <- as.data.frame(prADgt_num)
write.csv(prAD_data, "PR_RDA.csv", row.names = T)
#'impute missing data and check to see if NAs are gone, PCAdapt can't work with
#'missing values, code below is a 'mode imputation method' uses freq of genotypes
#'best if genotypes are in data.frame for manipulation
prAD_data.imp <- apply(prAD_data, 1, function(x) 
  replace(x, is.na(x), as.numeric(names(which.max(table(x))))))
#'check if data still has NAs
sum(is.na(prAD_data.imp))
#' sum of NAs = 0, it worked.

#'read in populations list
pop <- read.table("pop_map.txt", header = F)
pr.pop <- pop[,2]
#' we now have 93 indvs/pops. matching 2,762 genotype obs.

#'PCAdapt requires a pcadapt_class object, convert matrix to pcadapt_class with
#'the read.pcadapt() function
pca_genotype <- read.pcadapt(t(prAD_data.imp))
#'before we complete the PCAdapt analysis, we first need to examine the data 
#'to determine how many clusters (“K”) are supported by the data. code below allows
#'to test for this by examining the scree plot using PCA.
K <- 25
x <- pcadapt(pca_genotype, K = K)
plot(x, option = "screeplot") 
#'4 to 5 popn. groups/clusters seem well supported by PCs.

#'PC of how variation is partitioned among individuals/pops
plot(x, option = "scores", pop = pr.pop)

#'based on the screeplot and PCA lets select the best supported number of clusters
#'for the data, and assign K that number. I have chosen 3 populations for the 
#'PCAdapt analysis.
K <- 3
#'a MAF of 5% was set because imputation of genotypes by chance may have introduced
#'minor alleles
x <- pcadapt(pca_genotype, K = K, min.maf = 0.05)
#'view summary 
summary(x)
#'lets look at the QQ plot to assess model fit
plot(x, option = "qqplot", threshold = 0.1)
#'divergence was high at K=4, it reduced and when K=3, and increased considerably
#'when K=2, so we can safely adopt either K=3.

#'we have now assessed fit and we can now make a Manhattan plot to identify loci
#'with highest p-values (potential candidates).
plot(x, option = "manhattan")
#'loci that are far above the cloud are potential outliers and may represent 
#'adaptive differences.
#'lets now plot a distribution of Mahalanobis distances estimated by the PCAdapt
plot(x, option = "stat.distribution")
#'identify loci that fall outside of the normal distribution, considered outliers.
qval <- qvalue(x$pvalues)$qvalues
#'adjust the alpha value (as desired) to less stringent
alpha <- 0.0001 
outliers_pcadapt <- which(qval < alpha)
print(outliers_pcadapt)
#'only 1 loci was identified as an outlier, its unlikely that we will find the
#'same loci using OutFLANK as a confirmatory analysis.

#'genetic diversity
#'compute basic statistics - Ho, He, Gis etc per population
gen_div <- basic.stats(pr80)
str(gen_div)
ho <- gen_div$Ho
he <- gen_div$Hs
fis <- gen_div$Fis
# apply mean to each column (which represents a population)
ho_by_pop <- apply(ho, 2, mean, na.rm = TRUE)
he_by_pop <- apply(he, 2, mean, na.rm = TRUE)
fis_by_pop <- apply(fis, 2, mean, na.rm = TRUE)
#'save diversity metrics in df
stats_df <- data.frame(
  Population = colnames(ho),
  Ho = ho_by_pop,
  He = he_by_pop,
  Fis = fis_by_pop
)
#'check results
print(stats_df)
#'export data
write.csv(stats_df, "het_all_pops.csv", row.names = F)

#'heterozygosity estimates by sites for indvs per popn (done with vcftools)
popAR <- read.table("popAR_heterozygosity.het", sep = "\t", header = T)
write.csv(popAR, "popAR_het.csv", row.names = F)
popKL <- read.table("popKL_heterozygosity.het", sep = "\t", header = T)
write.csv(popKL, "popKL_het.csv", row.names = F)
popIR <- read.table("popIR_heterozygosity.het", sep = "\t", header = T)
write.csv(popIR, "popIR_het.csv", row.names = F)
popMR <- read.table("popMR_heterozygosity.het", sep = "\t", header = T)
write.csv(popMR, "popMR_het.csv", row.names = F)
popDD <- read.table("popDD_heterozygosity.het", sep = "\t", header = T)
write.csv(popDD, "popDD_het.csv", row.names = F)

#'genetic relatedness (relatedness for indvs. in data, based on Yang et al., 2010, 
#'unadjusted AJK statistic - expected proportion of alleles at a locus based on
#'shared ancestry).
pr93R <- read.table("pr93R.relatedness", sep = "\t", header = T)
#'view data
pr93R
#'convert NaNs to NAs and remove from data
pr93R[is.nan(pr93R$RELATEDNESS_AJK), "RELATEDNESS_AJK"] <- NA
pr93R <- na.omit(pr93R)
#'create matrix of unique indvs.
unique_indvs <- unique(c(pr93R$INDV1, pr93R$INDV2))
#'create empty matrix and fill with unique indvs
r_mat <- matrix(NA, nrow = length(unique_indvs), ncol = length(unique_indvs))
rownames(r_mat) <- unique_indvs
colnames(r_mat) <- unique_indvs
#'lets populate the r_mat with AJK statistic values
for (i in 1:nrow(pr93R)) {
  ind1 <- pr93R$INDV1[i]
  ind2 <- pr93R$INDV2[i]
  r_mat[ind1, ind2] <- pr93R$RELATEDNESS_AJK[i]
  r_mat[ind2, ind1] <- pr93R$RELATEDNESS_AJK[i]
}
#'make self comparisons to have a value of 1
diag(r_mat) <- 1
#'replace any remnant NAs with 0
r_mat[is.na(r_mat)] <- 0
#'plot output
pheatmap(r_mat,
         cluster_rows = F,
         cluster_cols = F,
         fontsize = 10,
         fontsize_col = 8,
         fontsize_row = 8,
         legend_breaks = c(-2,0,2,4,6,8),
         fontsize_number = 2,
         )
#'HWE - (Wigginton, Cutler and Abecasis 2005 - test how many observed genotypes 
#'significantly departed from neutral genetic drift).
pr93H <- read.table("pr93H.hwe", sep = "\t", header = T)
#'view data
pr93H
#'HWE using 📦 pegas
pr80_loci <- as.loci(pr80)
#'perform HWE with 1000 permutations for sign. testing
hwe_result <- hw.test(pr80_loci, B = 1000)
#'check result
print(hwe_result)
#'manipulate data
hwe_data <- as.data.frame(hwe_result)
hwe_data$Locus <- rownames(hwe_data)
hwe_data <- hwe_data %>% 
  mutate(neg_log10_p = -log10(`Pr(chi^2 >)`))
#'plot data
ggplot(hwe_data, aes(x = Locus, y = neg_log10_p)) +
  geom_bar(stat = "identity", fill = "steelblue") +  
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "red") +
  labs(x = "Loci", y = "-log10(p-value)") + 
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  
    axis.ticks.x = element_blank()
  )
#'Fst - Weir & Cockerham's 1984, pairwise comparison by popn
Fst_pops <- pairwise.WCfst(pr80.hfstat)
#'save output
write.csv(Fst_pops, "Fst_pops.csv", row.names = T)
#'output stored.

############################### END ##########################################

