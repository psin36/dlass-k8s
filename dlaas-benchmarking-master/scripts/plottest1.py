from matplotlib import pyplot as plt;
from pylab import genfromtxt;
# Created by: Parijat Dube

mat0 = genfromtxt("1_1.out");
mat1 = genfromtxt("1_2.out");
mat2 = genfromtxt("1_4.out");
mat3 = genfromtxt("2_4.out");
mat4 = genfromtxt("2_4_SS_50K.out");
# plot accuracy vs elapsed time in seconds.
fig = plt.figure(1)
plt.plot(mat0[:,1], mat0[:,2], label = "1x1");
plt.plot(mat1[:,1], mat1[:,2], label = "1x2");
plt.plot(mat2[:,1], mat2[:,2], label = "1x4");
plt.plot(mat3[:,1], mat3[:,2], label = "2x4");
plt.plot(mat4[:,1], mat4[:,2], label = "2x4_SS_50K");
plt.xlabel('Elapsed Training Time (sec)', fontsize=18)
plt.ylabel('Accuracy', fontsize=18)
plt.legend(loc=0);
plt.show();
fig.savefig('acurrracyTime.jpg')

# plot loss vs elapsed time in seconds.
fig = plt.figure(2)
plt.plot(mat0[:,1], mat0[:,3], label = "1x1");
plt.plot(mat1[:,1], mat1[:,3], label = "1x2");
plt.plot(mat2[:,1], mat2[:,3], label = "1x4");
plt.plot(mat3[:,1], mat3[:,3], label = "2x4");
plt.plot(mat4[:,1], mat4[:,3], label = "2x4_SS_50K");
plt.xlabel('Elapsed Training Time (sec)', fontsize=18)
plt.ylabel('Loss', fontsize=18)
plt.legend(loc=0);
plt.show();
fig.savefig('lossTime.jpg')

# plot accuracy vs iterations .
fig = plt.figure(3)
plt.plot(mat0[:,0], mat0[:,2], label = "1x1");
plt.plot(mat1[:,0], mat1[:,2], label = "1x2");
plt.plot(mat2[:,0], mat2[:,2], label = "1x4");
plt.plot(mat3[:,0], mat3[:,2], label = "2x4");
plt.plot(mat4[:,0], mat4[:,2], label = "2x4_SS_50K");
plt.xlabel('Iteration #', fontsize=18)
plt.ylabel('Accuracy', fontsize=18)
plt.legend(loc=0);
plt.show();
fig.savefig('acurrracyIter.jpg')

# plot loss vs iterations .
fig = plt.figure(4)
plt.plot(mat0[:,0], mat0[:,3], label = "1x1");
plt.plot(mat1[:,0], mat1[:,3], label = "1x2");
plt.plot(mat2[:,0], mat2[:,3], label = "1x4");
plt.plot(mat3[:,0], mat3[:,3], label = "2x4");
plt.plot(mat4[:,0], mat4[:,3], label = "2x4_SS_50K");
plt.xlabel('Iteration #', fontsize=18)
plt.ylabel('loss', fontsize=18)
plt.legend(loc=0);
plt.show();
fig.savefig('lossIter.jpg')
