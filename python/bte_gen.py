#Parser of Baka-Tsuki ePUB generator page
#python3
import requests, re
from bs4 import BeautifulSoup

class bte_gen(BeautifulSoup):
    def __init__(self, query):
        self.query = query
        self.result = dict()
        self.bteUrl = "http://ln.m-chan.org/v3/"
        self.bteGenHead = requests.get(self.bteUrl)
        self.bteGenHead.raise_for_status()
        super().__init__(self.bteGenHead.text)
        self.matches = self.find_all("a", text=re.compile(query, re.IGNORECASE))

    def perform_search(self):
        for match in self.matches:
            listLinks = []
            bteGenMatchContent = requests.get(self.bteUrl + match['href'])
            listBooksSoup = BeautifulSoup(bteGenMatchContent.text)
            listBooks = listBooksSoup.find_all("tr")
            listBooks.pop(0) #pop header
            for book in listBooks:
                #volume_number = book.td.find_next("td").string
                volume_number = book.td.next_sibling.next_sibling
                volume_name   = volume_number.next_sibling.next_sibling
                volume_text   = "Volume"
                if volume_number.string:
                    volume_text+= " {}".format(volume_number.string)
                if volume_name.string:
                    volume_text+= " {}".format(volume_name.string)
                listLinks.append("{0}: {1}{2}".format(volume_text, self.bteUrl, book.td.a['href']))
            if listLinks: self.result[match.string] = listLinks
        return any(listLinks)

    def print_findings(self):
        for key, value in self.result.items():
            print(key)
            for val in value:
                print(val)

