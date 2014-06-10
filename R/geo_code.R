#' Geocodign API Wrapper
#' 
#' A geocoding API that works with 
#' \href{http://geoservices.tamu.edu/Services/Geocode/}{Texas A & M Geoservices}.
#' 
#' @param street A street portion of the address.
#' @param city A city.
#' @param state A state abbreviation.
#' @param zip A zip code.
#' @param api.key A \href{http://geoservices.tamu.edu/Services/Geocode/WebService/}{Texas A & M Geoservices API key}
#' @return Returns a \code{data.frame} with latidue and longitude values.
#' @references \url{http://geoservices.tamu.edu/Services/Geocode/WebService/}
#' @keywords geocode
#' @export
#' @author Bryan Goodrich and Tyler Rinker <tyler.rinker@@gmail.com>.
#' @note To receive an API key the user must 
#' \href{http://geoservices.tamu.edu/Pricing/Partner/}{qualify} and then sing up: \url{https://geoservices.tamu.edu/Signup/}.
geo_code <- function(street, city, state, zip, api.key){

    ## address for geocoding
    addresse <- paste(street, city, state, zip, sep="+")   
    len <- length(addresses)
    latitude <- vector("numeric", len)
    longitude <- vector("numeric", len)
    
    for (i in seq(addresses)) {
        x <- try(csus_geocode(addresses[i], api.key = api.key))
        if (inherits(x, "try-error")) x <- rep(NA, 2)
        latitude[i]  <- x[1]
        longitude[i] <- x[2]
        print(sprintf("%s of %s", i, len)); flush.console()
        Sys.sleep(0.1)  # Suspend requests for a tenth of a second
    }  # end of function
    data.frame(latitude = latitude, longitude = longitude, 
    	stringsAsFactors = FALSE)
}


csus_geocode <- function(ADDRESS, api.key){

    address <- tolower(unlist(strsplit(ADDRESS, "\\+")))
    address <- sapply(address, function(x) gsub(" ", "%20", x))
    root <- "http://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsed_V04_01.aspx?streetAddress="
    end <- "&format=XML&census=false&notStore=false&version=4.01"
    URL <- sprintf("%s%s&city=%s&state=%s&zip=%s&apikey=%s%s", root, address[1], 
    	address[2], address[3], address[4], api.key, end)
    x <- requestXML(URL)$OutputGeocodes$OutputGeocode
    c(lat = as.numeric(x$Latitude), lng = as.numeric(x$Longitude))
} #end of function


requestXML <- function(URL) { #address to coordinates function
    xmlRequest <- RCurl::getURL(URL)
    xmlRequest <- substr(xmlRequest, 4, nchar(xmlRequest)) #removes 4 garbage characters at the begining
    xml <- XML::xmlToList(xmlRequest)
    return(xml)
}#end of address to coordinates function