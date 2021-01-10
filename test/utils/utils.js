
// getTimestamp(2010,10,13,"03");
function getTimestamp(year,month,day,hour) {
    
    let time = Math.floor(new Date(`${year}-${month}-${day}T${hour}:00:00`).getTime() / 1000); //seconds
    return time;
}

module.exports = {
    getTimestamp
}