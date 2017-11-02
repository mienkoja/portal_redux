# Measuring Days to First Visit from Original Placement Date

The following code makes use of data from the `oliver_replica` database to extract the average number of days between a child's original placement date, and the date of their first visit.

## Default Filter Values

These data are almost certainly an overestimate of the **true** average value. 

### Setting Location to Spokane

The numbers in Spokane County (and other counties in the Family Impact Network (FIN)) should be considered more trustworthy than numbers in other counties. This is because providers within FIN have been using Oliver for longer than providers in other parts of the state. Individuals within this geographic area also appear to be using Oliver more consistently than providers in other parts of the state. 

### Setting Days to 90

It may take months, or even years, after the start of a dependency episode for parents to become involved in a case. For example, one parent may be estranged and not even aware of the dependency case until the state locates them and serves them with court paperwork. 

Values less than 90 days should also be considered more trustworthy than values greater than 90 days. As such, the default values for the tool are for periods less than 90 days and in Spokane County. 

The assumption of this script is that there is a connection named `conn` to the `oliver_replica` database. 


```
## <PostgreSQLResult>
```


```r
service_referrals <- tbl(conn, sql("SELECT *
                                   , json_array_elements(\"childDetails\") ->> \'childOpd\' AS child_placement_date 
                                   FROM staging.\"ServiceReferrals\"")) %>%
  filter(isCurrentVersion == TRUE,
         is.na(deletedAt),
         !is.na(id),
         !is.na(child_placement_date)) %>%
  as_data_frame() %>%
  mutate(child_placement_date = as.Date(child_placement_date, format = "%m/%d/%Y")) %>%
  group_by(caseNumber, id) %>%
  summarise(first_placement_date = min(child_placement_date)) %>%
  filter(lubridate::year(first_placement_date) >= 2016)

visit_reports <- tbl(conn, "VisitReports") %>%
  filter(isCurrentVersion == TRUE,
         is.na(deletedAt),
         !is.na(serviceReferralId),
         !is.na(date)) %>%
  group_by(caseNumber, serviceReferralId) %>%
  summarise(first_visit_date = min(date)) %>%
  as_data_frame()

visit_reports_all <- tbl(conn, "VisitReports") %>%
  filter(isCurrentVersion == TRUE,
         is.na(deletedAt),
         !is.na(serviceReferralId),
         !is.na(date)) %>%
  select(date, visitLocationCounty, caseNumber) %>%
  as_data_frame()

first_visit_reports <- inner_join(service_referrals
           ,visit_reports
           ,by = c("caseNumber", "id" = "serviceReferralId")) %>%
  mutate(days_in_placement = as.numeric(first_visit_date - first_placement_date)) %>%
  filter(days_in_placement >= 0) %>%
  arrange(caseNumber, first_placement_date) %>%
  distinct(caseNumber, .keep_all = TRUE)  


first_visit_and_locale <- inner_join(visit_reports_all
           ,first_visit_reports, by = c("date" = "first_visit_date", "caseNumber")) %>%
  select(days_in_placement, jurisdiction = visitLocationCounty) %>%
  mutate(jurisdiction = ifelse(jurisdiction == "Curry/Roosevelt", "Klickitat", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "99341", "Adams", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "grant", "Grant", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Benton County", "Benton", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Stevens County", "Stevens", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "99201", "Spokane", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Kitittas", "Kittitas", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "UNited States", NA, jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "whitman", "Walla Walla", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Pima", "King", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Newport", "Pend Oreille", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Cherokee", "Okanogan", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Moses lake", "Grant", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "WHITMAN", "Whitman", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Kittittas", "Kittitas", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "SNohomish", "Snohomish", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Spokane County", "Spokane", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Spokane county", "Spokane", jurisdiction)         
         ,jurisdiction = ifelse(jurisdiction == "Lynnwood", "Snohomish", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "AdamsCounty", "Adams", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Moses lake", "Grant", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "stevens", "Stevens", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Pend Oreille County", "Pend Oreille", jurisdiction)
         ,jurisdiction = ifelse(jurisdiction == "Pend O'Reille", "Pend Oreille", jurisdiction)    
         ,jurisdiction = ifelse(jurisdiction == "king", "King", jurisdiction)  
         ,jurisdiction = ifelse(jurisdiction == "Fraklin", "Franklin", jurisdiction)    
         ,jurisdiction = ifelse(jurisdiction == "SPOKANE", "Spokane", jurisdiction) 
         ,jurisdiction = ifelse(jurisdiction == "spokane", "Spokane", jurisdiction)          
         ,jurisdiction = ifelse(jurisdiction == "WA", "Unknown", jurisdiction)           
         ,jurisdiction = ifelse(is.na(jurisdiction), "Unknown", jurisdiction)   
  ) 

# a little code to check for bad county names 
# should be automated and regexified if this ever becomes a prod measurement

# good_county_names <- read.csv(file = "https://raw.githubusercontent.com/hadley/data-counties/master/county-fips.csv"
#                               ,header = TRUE
#                               ,sep = ",") %>%
#   filter(state == "WA")

# anti_join(select(first_visit_and_locale, county = jurisdiction)
#           ,good_county_names) %>%
#   distinct()

first_visit_and_locale %>% feather::write_feather("days_in_placement")
```

The file save here, is used to power the rest of the shiny application. A link to the entire repo is as follows: https://github.com/mienkoja/portal_redux
