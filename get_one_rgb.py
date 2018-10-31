from PIL import Image
import colorsys
import matplotlib.pyplot as plt
from sklearn.cluster import MiniBatchKMeans
import numpy as np
from collections import Counter
from os import listdir
from os.path import isfile, join

def get_rgb(file, kmeans=True, n_clusters=1):
    print("get_rgb is working")
    im = Image.open(file)
    vals = np.array(im)
    #print(np.shape(vals))

    # convert RGB to [0,1] scale
    # 864*368 to rozdzielczosc screenshota
    vals = vals.reshape((864*368, 3))/255
    if kmeans:
        # fit K-Means to frame's colors
        algo = MiniBatchKMeans(n_clusters=n_clusters, random_state=0).fit(vals)
        hls_centers = []
        for i in range(len(algo.cluster_centers_)):
            rgb_center = (algo.cluster_centers_[i][0], algo.cluster_centers_[i][1], algo.cluster_centers_[i][2])
            # convert RGB to HLS
            hls_centers.append(tuple((np.array(colorsys.rgb_to_hls(*rgb_center)))))
        hls = list(map(lambda x: tuple(hls_centers[x]), algo.predict(vals)))
    else:
        hls = list(map(lambda x: colorsys.rgb_to_hls(*x), vals))
    #sort colors via hue
    hls.sort()
    rgb = list(map(lambda x: tuple((np.array(colorsys.hls_to_rgb(*x))*255).astype('uint8')), hls))
    return rgb


def get_one_rgb(file):
    rgb = get_rgb(file)
    return rgb[1]


# directory musi sie konczyc "/" zeby potem powstala poprawna sciezka
def movie_vector(directory):
    onlyfiles = [f for f in listdir(directory) if isfile(join(directory, f))]
    i = 1
    n = len(onlyfiles)
    result = [] #list of color RGB tuples for every screenshot
    for f in onlyfiles:
        print("{0} z {1} ".format(i, n), end="")
        cur_color = get_one_rgb(directory+f)
        result.append(cur_color)
        i += 1
    return result


def vector_to_csv(directory, output_dir, name = "movie_colours.csv"):
    """
    Tworzy .csv z jednym kolorem dla kazdego screenshota
    :param directory: sciezka folderu ze screenshotami zakonczona "/"
    :param output_dir: sciezka do zapisu pliku csv
    :param name: nazwa pliku csv
    :return: plik csv z kolorami dla screenshotow-> colnames=c(R, G, B)
    """
    movie_vector0 = movie_vector(directory)
    vec = np.array(movie_vector0)
    np.savetxt(output_dir+name, vec) # to w sumie dziala
    #vec.tofile(output_dir+name, sep=",", format='%10.5f')


def image_create(data_csv):
    """
    Tworzy .png ze sepktrum kolorow dla filmu
    :param data_csv: lokalizacja pliku csv z kolorami dla screenshotow (wyniku funkcji vector_to_csv)
    :return: .png ze spektrum kolorow
    """
    output_dir = '/media/ghost/shared/MiNI.Data_Science/3_semestr/TWD/p1/spectrum.png'
    data = np.genfromtxt(data_csv, dtype=np.int32)
    nrows = data.shape[0]
    height = 100
    width = 10
    im = Image.new('RGB', (width*nrows, height))
    for i in range(nrows):
        rgb = data[i]
        im.paste(tuple(rgb), (width * i, 0, width*(i+1), height))
    im.save(output_dir)

