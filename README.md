# NQ_DBSCAN
NQ_DBSCAN is a fast clustering algorithm based on pruning unnecessary distance computations in DBSCAN for high-dimensional data.
we propose a novel local neighborhood searching technique, and apply it to improve DBSCAN, named as
NQ-DBSCAN, such that a large number of unnecessary distance computations can be effectively reduced.
Theoretical analysis and experimental results show that NQ-DBSCAN averagely runs in O(n∗log(n)) with
the help of indexing technique, and the best case is O(n) if proper parameters are used, which makes it
suitable for many realtime data.
