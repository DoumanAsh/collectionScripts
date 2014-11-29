"""Parser of Baka-Tsuki ePUB generator page"""
#python3
import requests, re
from bs4 import BeautifulSoup

class bte_gen(BeautifulSoup):
    """ Base class of module """
    def __init__(self, query):
        self.query = query
        self.result = dict()
        self.bte_url = "http://ln.m-chan.org/v3/"
        self.bte_gen_head = requests.get(self.bte_url)
        self.bte_gen_head.raise_for_status()
        super().__init__(self.bte_gen_head.text)
        self.matches = self.find_all("a", text=re.compile(query, re.IGNORECASE))

    def update_query(self, new_query):
        """ Replace query and re-search with new one """
        self.query = new_query
        self.matches = self.find_all("a", text=re.compile(self.query, re.IGNORECASE))
        self.result = dict()
        return self.perform_search()

    def perform_search(self):
        """ Performs search and save results in self.result

            Format of result dictionary:
            { Novel's name : List of links }

            @return true if anything is found
            @return false otherwise
        """
        for match in self.matches:
            list_links = []
            matched_content = requests.get(self.bte_url + match['href'])
            books_soup = BeautifulSoup(matched_content.text)
            list_books = books_soup.find_all("tr")
            list_books.pop(0) #pop header
            for book in list_books:
                #volume_number = book.td.find_next("td").string
                volume_number = book.td.next_sibling.next_sibling
                volume_name = volume_number.next_sibling.next_sibling
                volume_text = "Volume"
                if volume_number.string:
                    volume_text += " {}".format(volume_number.string)
                if volume_name.string:
                    volume_text += " {}".format(volume_name.string)
                list_links.append("{0}: {1}{2}".format(volume_text, self.bte_url, book.td.a['href']))
            if list_links:
                self.result[match.string] = list_links
        return any(list_links)

    def print_findings(self):
        """ Printout of findings """
        for key, value in self.result.items():
            print(key)
            for val in value:
                print(val)

