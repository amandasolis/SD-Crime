library(R.matlab)

# load data into data frame
data<-readMat("SDCrimeData.mat")
df<-data.frame(data)

# load neighborhood names, rename df rows
neighborhoods<-readMat("neighborhoods.mat")
df_neighborhoods<-t(data.frame(neighborhoods))

colnames(df_neighborhoods) <- "Neighborhood"
rownames(df_neighborhoods) <- NULL

# add neighborhood names as row names and variable names as column names
row.names(df) <- df_neighborhoods
colnames(df) <- c("Murder", "Rape", "Armed Robbery", "ST/ARM Robbery", "Aggravated Assault", "Violent Crime Total", "Residential Burglary", "Non-residential Burglary", "Burglary Total", "$400+ Larceny-Theft", "<$400 Larceny-Theft", "Larceny-Theft Total", "Motor Vehicle Theft", "Property Crime Total", "Crime IDX TL", "Car Prowl")

# remove redundant columns 
df[15]<- NULL
df[14]<- NULL
df[12]<- NULL
df[9]<- NULL
df[6]<- NULL

View(df)
plot(df,pch=1, col=rgb(0,0,.5,0.5)) # plt pairwise scatter plots

# Get principal component vectors using prcomp
pc <- prcomp(df, scale.=TRUE, center=TRUE)
summary(pc)

std_dev <- pc$sdev
pc_var <- std_dev^2
proportion_variance <- pc_var/sum(pc_var)

dev.off()
plot(proportion_variance, xlab = "Principal Component", ylab = "Proportion of Variance Explained", type = "b")
dev.off()
plot(cumsum(proportion_variance), xlab = "Principal Component", ylab = "Cumulative Proportion of Variance Explained", type = "b")
abline(h=.90, col="blue")
text(3, .91, "90% explained", col = "blue")

scores <- pc$x
loadings <- pc$rotation
View (loadings)
sqrt(1/ncol(df)) # significant loadings have an absolute value greater than this output

par(mfrow=c(1,3)) 
biplot(scores[,1:2], loadings[,1:2])
biplot(scores[,2:3], loadings[,2:3])
biplot(scores[,3:4], loadings[,3:4])

# Chooose portion of principal components
comp <- data.frame(pc$x[,1:4])
plot(comp, pch=1, col=rgb(0,0,.5,0.5))
dev.off()

# plot to choose number of clusters
wss <- (nrow(comp)-1)*sum(apply(comp,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(comp,centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

# Apply k-means & plot
k <- kmeans(comp, centers=3, nstart=10000, iter.max=10000)
plot(comp, col=k$clust, pch=1)

# Cluster sizes
sort(table(k$clust))
clust <- names(sort(table(k$clust)))

# 3D plot
library(rgl)
plot3d(comp$PC1, comp$PC2, comp$PC3, col=k$clust)
text3d(comp$PC1, comp$PC2, comp$PC3, df_neighborhoods , cex=.8, adj=c(-.2,1))

# First cluster
row.names(comp[k$clust==clust[1],])
# Second Cluster
row.names(comp[k$clust==clust[2],])
# Third Cluster
row.names(comp[k$clust==clust[3],])
