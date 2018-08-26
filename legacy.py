
# 
# url = "https://www.matematicamente.it/forum/search.php?st=0&sk=t&sd=d&sr=posts&author_id=12354&start=2750"

# import urllib.request
# page = urllib.request.urlopen(url)
# print(page.read())



import mechanicalsoup

browser = mechanicalsoup.StatefulBrowser(
    user_agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
)
browser.open("https://www.matematicamente.it/forum/ucp.php")

browser.select_form('#login')
browser["username"] = "pippo"
browser["password"] = "pippo"
browser.submit_selected()

browser.launch_browser()

# Display the results
for link in browser.get_current_page().select('div.error'):
    print(link.text)
