

from selenium import webdriver 
from selenium.webdriver import Chrome
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import Select
import json
import re, time
import pandas as pd
from collections import defaultdict



def pull_state_link(web_link):
    '''
    Inputs: User inputted link for webpage (weblink)
    Outputs: Returns a Browser instance
    Purpose: Open Google Chrome automated instance based on inputted link and user must have chrome driver in PATH
    '''
    opts = Options()
    opts.add_argument('--headless')
    page = webdriver.Chrome(options=opts)
    page.get(web_link)
    return page


def pull_state_detail(page, state):
    '''
    Purpose: Scrape relevant state immigration statistics
    Inputs: Selenium Web page object
    Outpus: Dataframe of state immigration statistics
    '''
    foreign_born_stats = page.find_element_by_xpath('//table[@class="views-table cols-35"]')
    us_born_stats = page.find_element_by_xpath('//table[@class="views-table cols-28"]')
    median_wage_detail = page.find_elements_by_xpath('//tr[@class="row87"]')
    
    med = [re.sub('[^\d]','',med.text) for med in median_wage_detail if med.text.strip()!='']
    
    th_tags = foreign_born_stats.find_elements_by_xpath('.//th')
    td_tags = foreign_born_stats.find_elements_by_xpath('.//td')
    ths_list = [th.text for th in th_tags]
    tds_list = [td.text for td in td_tags]
    order = list(range(len(tds_list)))
    foreign_detail = pd.DataFrame(list(zip(order,ths_list[2:],tds_list)),columns=['order','header','foreign_born'])
    
    tds_us = us_born_stats.find_elements_by_xpath('.//td')
    tds_us_list = [td.text for td in tds_us]
    us_detail = pd.DataFrame(list(zip(order,tds_us_list)),columns=['order_us','us_born'])
    
    stats = foreign_detail.merge(us_detail,how='inner',left_on='order',right_on='order_us')
    stats['foreign_median_wages'] = med[0]
    stats['us_median_wages'] = med[1]
    stats['state'] = state
    return page, stats.loc[:7,['order','header','state','foreign_born','us_born','foreign_median_wages','us_median_wages']]



if __name__ == '__main__':
    st_abbrev = ['AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY']
    base_link = 'https://www.migrationpolicy.org/data/state-profiles/state/income/'
    output_df = pd.DataFrame()
    for state in st_end:
        page = pull_state_link(base_link+state+'#')
        page, data = pull_state_detail(page,state)
        output_df = pd.concat([output_df,data])
        page.close()
        output_df.to_csv('state_immigration_stats.csv')
