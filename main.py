import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

ratingdata = pd.read_csv("ml-1m/ratings.dat", delimiter="::", header=None, names=['UserID', 'MovieID', 'Ratings', 'Timestamp'], engine='python')
ratingdata = ratingdata[['UserID', 'MovieID', 'Ratings']]

cols, rows = 3952, 6040
data_set = pd.DataFrame(np.zeros((rows, cols)))

for index, row in ratingdata.iterrows():
    user_id = row['UserID'] - 1
    movie_id = row['MovieID'] - 1
    rating = row['Ratings']
    data_set.at[user_id, movie_id] = rating

km = KMeans(n_clusters=3, random_state=0)
km.fit(data_set)

y_km = km.predict(data_set)

pca = PCA(n_components=2)
data_set_2d = pca.fit_transform(data_set)

plt.scatter(
    data_set_2d[y_km == 0, 0], data_set_2d[y_km == 0, 1],
    s=50, c='lightgreen',
    marker='s', edgecolor='black',
    label='cluster 1'
)

plt.scatter(
    data_set_2d[y_km == 1, 0], data_set_2d[y_km == 1, 1],
    s=50, c='orange',
    marker='o', edgecolor='black',
    label='cluster 2'
)

plt.scatter(
    data_set_2d[y_km == 2, 0], data_set_2d[y_km == 2, 1],
    s=50, c='lightblue',
    marker='^', edgecolor='black',
    label='cluster 3'
)

# Centroids 시각화
centroids_2d = pca.transform(km.cluster_centers_)
plt.scatter(
    centroids_2d[:, 0], centroids_2d[:, 1],
    s=250, c='red',
    marker='*', edgecolor='black',
    label='centroids'
)

plt.legend(scatterpoints=1)
plt.grid()
plt.show()

data_set.replace(0, np.nan, inplace=True)

avg = data_set.mean(axis=1)
print("\nAverage:")
print(avg.head(10))

au = data_set.sum(axis=0)
print("\nAdditive Utilitarian:")
print(au.head(10))

s_count = data_set.count()
print("\nSimple Count:")
print(s_count.head(10))

approve = (data_set >= 4).sum()
print("\nApproval Voting:")
print(approve.head(10))

rank = data_set.rank(axis=1, method='average', na_option='keep') - 1
borda_count = rank.sum(axis=0)
print("\nBorda Count:")
print(borda_count.head(10))

com_rate = pd.DataFrame(np.nan, index=range(cols), columns=range(cols))
com_rate_sum = com_rate.sum(axis=0)

for i in range(cols):
    for j in range(i + 1, cols):
        if not np.isnan(borda_count.iloc[i]) and not np.isnan(borda_count.iloc[j]):
            if borda_count.iloc[i] > borda_count.iloc[j]:
                com_rate.at[i, j] = 1
                com_rate.at[j, i] = -1
            elif borda_count.iloc[i] < borda_count.iloc[j]:
                com_rate.at[i, j] = -1
                com_rate.at[j, i] = 1
            else:
                com_rate.at[i, j] = 0
                com_rate.at[j, i] = 0
print("\nCopeland Rule:")
print(com_rate_sum.head(10))







