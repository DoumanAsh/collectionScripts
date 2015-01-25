""" Sorting algorithms """
def insert_sort(list_num):
    """ Insertion sort

        Start from second element
        Save it alongside with it's index
        Run from previous element to first one
        While checking if value should be moved
        In the end, put saved value after last moved index
    """
    for i in range(1, len(list_num)):
        value = list_num[i]
        j = i - 1
        while (j >= 0) and (list_num[j] > value):
            list_num[j+1] = list_num[j]
            j -= 1
        list_num[j+1] = value
