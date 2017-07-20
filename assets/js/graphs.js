//////////////
////////////// graphs.js
////////////// Fyller opp siden med grafer.
//////////////
var searchWord = "";
var politicianWordFrequency = [];
var commentWordFrequency = [];
var politicianWordPercent = [];
var commentWordPercent = [];

//Facebook navnet til de utvalgte politikerne
var politiker = ["audunlysbakken", "bardvegar", "dagruneriksen", "ernasolberg", "geirsp", "hanna.e.marcussen", "JanTSanner", "jonasgahrstore", "Knut.Arild.Hareide", "Per.Sandberg.FrP", "rasmusjmhansson", "Siv.Jensen.FrP", "torbjornroeisaksen", "trinesg", "UneBastholm"];
var politikerFulltNavn = ["Audun Lysbakken", "Bård Vegar Solhjell", "Dagrun Eriksen", "Erna Solberg", "Geir Sannes Pedersen", "Hanna Marcussen", "Jan T Sanner", "Jonas Gahr Støre", "Knut Arild Hareide", "Per Sandberg", "Rasmus Hansson", "Siv Jensen", "Torbjørn Røe Isaksen", "Trine Skei Grande", "Une Bastholm"];
//Facebooknavnet til de utvalgte politikerne + -comments. Nødvendig for å finne riktige datafiler.
var politikerKommentarfelt = ["audunlysbakken-comments", "bardvegar-comments", "dagruneriksen-comments", "ernasolberg-comments", "geirsp-comments", "hanna.e.marcussen-comments", "JanTSanner-comments", "jonasgahrstore-comments", "Knut.Arild.Hareide-comments", "Per.Sandberg.FrP-comments", "rasmusjmhansson-comments", "Siv.Jensen.FrP-comments", "torbjornroeisaksen-comments", "trinesg-comments", "UneBastholm-comments"];

//Når søkeknappen trykkes skal siden bli oppdatert.
$("#searchButton").click(function() {
    updateWordSearch();
});

//Oppdaterer grafene
function updateWordSearch() {
    searchWord = $('#searchWord').val().toLowerCase(); //searchWord is set to the input value
    politicianWordFrequency = []; // array cleared
    commentWordFrequency = [] //array cleared
    $(".chart").empty(); //old charts removed
    for (var i = 0; i < politiker.length; i++) {
        //array to fill, where to look, number
        fillArray(politicianWordFrequency, politiker, i);
        fillArray(commentWordFrequency, politikerKommentarfelt, i);
    }
    $(".chart").append("<h2>Du søkte på: <span style='color:red'>" + searchWord + "</span></h2>");
}

// This function makes ajax calls to fill the politicianWordFrequency array
// Param: what to fill, where to look, number in array
function fillArray(array, look, number) {
    $.ajax({
        url: "data/Term_frequencies/" + look[number] + "-termFrequency.json",
        dataType: "text",
        success: function(data) {
            var json = $.parseJSON(data);
            $.each(json, function(i, jsonObjectList) {
                //if a value matches from the given json file matches the searchword, add it to the array
                if (jsonObjectList._row == searchWord) {
                    array.push({
                        politician: look[number].split("-")[0],
                        freq: jsonObjectList.freq,
                        percent: jsonObjectList.Percent
                    });
                }
            });
        }
    });
}

//This will not run before all ajax calls have been made
$(document).ajaxStop(function() {

    //Dersom ordet er brukt av politikere, lag stolpediagram
    if (politicianWordFrequency.length > 0) {
        $(".chart").append("<h3>Antall ganger ordet er nevnt i post</h3>");
        drawBar(politicianWordFrequency);
        $(".chart").append("<h3>Prosentvis ordet er nevnt i post</h3>");
        drawBarPercent(politicianWordFrequency);
    }

    //Dersom ordet er brukt i kommentarer, lag stolpediagram
    if (commentWordFrequency.length > 0) {
        $(".chart").append("<h3>Antall ganger ordet er nevnt i kommentar</h3>");
        drawBar(commentWordFrequency);
        $(".chart").append("<h3>Prosentvis ordet er nevnt i kommentar</h3>");
        drawBarPercent(commentWordFrequency);
    }
});

//Tegn stoplediagram
//param: array som inneholder navn og verdi
function drawBar(array) {
    var margin = {
            top: 20,
            right: 20,
            bottom: 30,
            left: 40
        },
        width = 1200 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(5, "");

    var svg = d3.select(".chart").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain(array.map(function(d) {
        return d.politician;
    }));
    y.domain([0, d3.max(array, function(d) {
        return d.freq;
    })]);

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Antall");


    svg.selectAll(".bar")
        .data(array)
        .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function(d) {
            return x(d.politician);
        })
        .attr("width", x.rangeBand())
        .attr("y", function(d) {
            return y(d.freq);
        })
        .attr("height", function(d) {
            return height - y(d.freq);
        });

    function type(d) {
        d.freq = +d.freq;
        return d;
    }
}

//lag bar chart som skal inneholde prosenter
function drawBarPercent(array) {
    var margin = {
            top: 20,
            right: 20,
            bottom: 30,
            left: 40
        },
        width = 1200 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(10, "%");

    var svg = d3.select(".chart").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain(array.map(function(d) {
        return d.politician;
    }));
    y.domain([0, d3.max(array, function(d) {
        return d.percent;
    })]);

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Prosent");

    svg.selectAll(".bar")
        .data(array)
        .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function(d) {
            return x(d.politician);
        })
        .attr("width", x.rangeBand())
        .attr("y", function(d) {
            return y(d.percent);
        })
        .attr("height", function(d) {
            return height - y(d.percent);
        });

    function type(d) {
        d.percent = +d.percent;
        return d;
    }
}


////////////////////////////////////////////////
//////////////// Statistikk ////////////////////
////////////////////////////////////////////////
var statsArray = [];


function readTextFile(file, callback) {
    var rawFile = new XMLHttpRequest();
    rawFile.overrideMimeType("application/json");
    rawFile.open("GET", file, true);
    rawFile.onreadystatechange = function() {
        if (rawFile.readyState === 4 && rawFile.status == "200") {
            callback(rawFile.responseText);
        }
    }
    rawFile.send(null);
}

readTextFile("data/Politician_info/AggregatedPoliticianInfo.json", function(text) {
    statsArray = JSON.parse(text);

    var meanLikes = [];
    var meanComments = [];
    var meanShares = [];
    var meanWords = [];
    //Fyller opp politikerprofilene, forferdelig kode, men dårlig tid.
    for (var i = 0; i < statsArray.length; i++) {

        if (statsArray[i][0].from == "ernasolberg") {
            $("#erna-info").append("<h3>Post med flest likes</h3>");
            $("#erna-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#erna-info").append("<h3>Post med flest delinger</h3>");
            $("#erna-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "Siv.Jensen.FrP") {
            $("#siv-info").append("<h3>Post med flest likes</h3>");
            $("#siv-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#siv-info").append("<h3>Post med flest delinger</h3>");
            $("#siv-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "jonasgahrstore") {
            $("#jonas-info").append("<h3>Post med flest likes</h3>");
            $("#jonas-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#jonas-info").append("<h3>Post med flest delinger</h3>");
            $("#jonas-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "Knut.Arild.Hareide") {
            $("#knut-info").append("<h3>Post med flest likes</h3>");
            $("#knut-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#knut-info").append("<h3>Post med flest delinger</h3>");
            $("#knut-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "audunlysbakken") {
            $("#audun-info").append("<h3>Post med flest likes</h3>");
            $("#audun-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#audun-info").append("<h3>Post med flest delinger</h3>");
            $("#audun-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "trinesg") {
            $("#trine-info").append("<h3>Post med flest likes</h3>");
            $("#trine-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#trine-info").append("<h3>Post med flest delinger</h3>");
            $("#trine-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "Per.Sandberg.FrP") {
            $("#per-info").append("<h3>Post med flest likes</h3>");
            $("#per-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#per-info").append("<h3>Post med flest delinger</h3>");
            $("#per-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "rasmusjmhansson") {
            $("#rasmus-info").append("<h3>Post med flest likes</h3>");
            $("#rasmus-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#rasmus-info").append("<h3>Post med flest delinger</h3>");
            $("#rasmus-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "JanTSanner") {
            $("#jan-info").append("<h3>Post med flest likes</h3>");
            $("#jan-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#jan-info").append("<h3>Post med flest delinger</h3>");
            $("#jan-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "torbjornroeisaksen") {
            $("#torbjorn-info").append("<h3>Post med flest likes</h3>");
            $("#torbjorn-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#torbjorn-info").append("<h3>Post med flest delinger</h3>");
            $("#torbjorn-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "dagruneriksen") {
            $("#dagrun-info").append("<h3>Post med flest likes</h3>");
            $("#dagrun-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#dagrun-info").append("<h3>Post med flest delinger</h3>");
            $("#dagrun-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "geirsp") {
            $("#geir-info").append("<h3>Post med flest likes</h3>");
            $("#geir-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#geir-info").append("<h3>Post med flest delinger</h3>");
            $("#geir-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "bardvegar") {
            $("#bard-info").append("<h3>Post med flest likes</h3>");
            $("#bard-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#bard-info").append("<h3>Post med flest delinger</h3>");
            $("#bard-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "UneBastholm") {
            $("#une-info").append("<h3>Post med flest likes</h3>");
            $("#une-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#une-info").append("<h3>Post med flest delinger</h3>");
            $("#une-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        } else if (statsArray[i][0].from == "hanna.e.marcussen") {
            $("#hanna-info").append("<h3>Post med flest likes</h3>");
            $("#hanna-info").append("<p>" + statsArray[i][0].mostLikedMessage + "</p>");
            $("#hanna-info").append("<h3>Post med flest delinger</h3>");
            $("#hanna-info").append("<p>" + statsArray[i][0].mostSharedMessage + "</p>");
        }


        meanLikes.push({
            verdi: statsArray[i][0].meanLikes
        });

        meanComments.push({
            verdi: statsArray[i][0].meanComments
        });

        meanShares.push({
            verdi: statsArray[i][0].meanShares
        });

        meanWords.push({
            verdi: statsArray[i][0].meanWordCount
        });
    }

    //Mean likes piechart
    var meanLikesTitle = "Gjennomsnittlig antall likes";
    var meanLikesDesc = "Viser hvor mange likes de forskjellige politikerne har fått";
    makePie(meanLikesTitle, meanLikesDesc, meanLikes, "pieChart");

    //Mean comments piechart
    var meanCommentTitle = "Gjennomsnittlig antall kommentarer";
    var meanCommentDesc = "Viser hvor mange kommentarer de forskjellige politikerne har fått";
    makePie(meanCommentTitle, meanCommentDesc, meanComments, "pieChart2");

    //Mean shares piechart
    var meanSharesTitle = "Gjennomsnittlig antall delinger";
    var meanSharesDesc = "Viser hvor mange delinger de forskjellige politikerne har fått";
    makePie(meanSharesTitle, meanSharesDesc, meanShares, "pieChart3");

    //Mean shares piechart
    var meanWordTitle = "Gjennomsnittlig antall ord";
    var meanWordDesc = "Viser hvor mange ord som blir brukt i postene, vanligste ord er fjernet";
    makePie(meanWordTitle, meanWordDesc, meanWords, "pieChart4");

});

//Lager piediagram. Tar inn tittel, beskrivelse og verdier.
function makePie(tittel, beskrivelse, value, container) {
    var pie = new d3pie(container, {
        "header": {
            "title": {
                "text": tittel,
                "fontSize": 24,
                "font": "open sans"
            },
            "subtitle": {
                "text": beskrivelse,
                "color": "#999999",
                "fontSize": 12,
                "font": "open sans"
            },
            "titleSubtitlePadding": 9
        },
        "footer": {
            "color": "#999999",
            "fontSize": 10,
            "font": "open sans",
            "location": "bottom-left"
        },
        "size": {
            "canvasWidth": 550,
            "pieOuterRadius": "59%"
        },
        "data": {
            "sortOrder": "value-asc",
            "content": [{
                "label": "Erna Solberg",
                "value": value[0].verdi[0],
                "color": "#7e6838"
            }, {
                "label": "Siv Jensen",
                "value": value[1].verdi[0],
                "color": "#384a7e"
            }, {
                "label": "Jonas Gahr Støre",
                "value": value[2].verdi[0],
                "color": "#4a7e38"
            }, {
                "label": "Knut Arild Hareide",
                "value": value[3].verdi[0],
                "color": "#5f7e38"
            }, {
                "label": "Audun Lysbakken",
                "value": value[4].verdi[0],
                "color": "#45387e"
            }, {
                "label": "Trin Skei Grande",
                "value": value[5].verdi[0],
                "color": "#387e42"
            }, {
                "label": "Per Sandberg",
                "value": value[6].verdi[0],
                "color": "#385c7e"
            }, {
                "label": "Rasmus Hansson",
                "value": value[7].verdi[0],
                "color": "#387e5c"
            }, {
                "label": "Jan T Sanner",
                "value": value[8].verdi[0],
                "color": "#7e5038"
            }, {
                "label": "Torbjørn Røe Isaksen",
                "value": value[9].verdi[0],
                "color": "#767e38"
            }, {
                "label": "Dagrun Eriksen",
                "value": value[10].verdi[0],
                "color": "#387e73"
            }, {
                "label": "Geir Sannes Pedersen",
                "value": value[11].verdi[0],
                "color": "#53387e"
            }, {
                "label": "Bård Vegar Solhjell",
                "value": value[12].verdi[0],
                "color": "#384a7e"
            }, {
                "label": "Une Bastholm",
                "value": value[13].verdi[0],
                "color": "#386d7e"
            }, {
                "label": "Hanna Marcussen",
                "value": value[14].verdi[0],
                "color": "#7e3838"
            }]
        },
        "labels": {
            "outer": {
                "format": "label-value1",
                "pieDistance": 32
            },
            "inner": {
                "format": "none"
            },
            "mainLabel": {
                "fontSize": 11
            },
            "percentage": {
                "color": "#ffffff",
                "decimalPlaces": 0
            },
            "value": {
                "color": "#adadad",
                "fontSize": 11
            },
            "lines": {
                "enabled": true
            },
            "truncation": {
                "enabled": true
            }
        },
        "tooltips": {
            "enabled": true,
            "type": "placeholder",
            "string": "{label}: {value}"
        },
        "effects": {
            "load": {
                "speed": 750
            },
            "pullOutSegmentOnClick": {
                "effect": "linear",
                "speed": 400,
                "size": 8
            }
        },
        "misc": {
            "pieCenterOffset": {
                "x": -25
            }
        }
    });
}

////
//// Chord graph
////
// Hvor mange ganger hver politiker blir nevnt av andre
var matrix = [
    [0, 3, 2, 0, 0, 0, 3, 1, 1, 0, 2, 2, 0, 0, 0], //Erna x
    [2, 0, 5, 1, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0], //Siv x
    [6, 2, 0, 0, 0, 0, 3, 1, 2, 0, 1, 0, 0, 0, 0], //Jonas x
    [0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], //Trine x
    [5, 3, 3, 0, 0, 0, 4, 1, 7, 0, 0, 0, 0, 4, 0], //Audun x
    [2, 6, 0, 0, 0, 4, 6, 2, 5, 2, 0, 0, 0, 1, 0], //Geir x
    [5, 0, 0, 0, 0, 0, 0, 1, 1, 0, 2, 0, 0, 0, 0], //Jan x
    [1, 0, 0, 2, 0, 0, 2, 1, 1, 0, 0, 0, 0, 0, 0], //Knut x
    [1, 4, 4, 0, 2, 0, 0, 0, 12, 0, 0, 0, 3, 0, 0], //Per x
    [1, 0, 3, 2, 1, 0, 1, 2, 0, 0, 0, 1, 0, 0, 1], //Rasmus x
    [1, 0, 0, 0, 0, 1, 2, 1, 1, 0, 1, 0, 0, 1, 0], //Torbjørn x
    [0, 2, 0, 1, 0, 0, 0, 0, 0, 9, 0, 1, 0, 0, 0], //Une x
    [0, 1, 0, 0, 0, 0, 1, 4, 1, 0, 0, 0, 26, 0, 0], //Dagrun x
    [0, 0, 0, 1, 2, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1], //Bard
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 0], //hanna
];

//Politikere
var chordPoliticians = ["Erna Solberg", "Siv Jensen", "Jonas Gahr Støre", "Trine Skei Grande", "Audun Lysbakken", "Geir Sannes Pedersen", "Jan T Sanner", "Knut Arild Hariede", "Per Sandberg", "Rasmus Hansson", "Torbjørn Røe Isaksen", "Une Bastholm", "Dagrun Eriksen", "Bård Vegar Solhjell", "Hanna Marcussen"];
//Fargerkoder
var chordColors = ["#000000", "#FFDD89", "#957244", "#F26223", "#727272", "#f1595f", "#79c36a", "#599ad3", "#f9a65a", "#9e66ab", "#cd7058", "#d77fb3", "#03C03C", "#779ECB", "#C23B22"];


//Lager tekststreng der hver politiker får tildelt en farge. Dette er fargen de har i chord grafen
$(".pol-names").append("<p>");
for (var i = 0; i < chordPoliticians.length; i++) {
    $(".pol-names").append("<span style=' color: " + chordColors[i] + "'>" + chordPoliticians[i] + " </span>");
}
$(".pol-names").append("</p>");

makeChord();

//Lager en chord graf
function makeChord() {
    var chord = d3.layout.chord()
        .padding(.06)
        .sortSubgroups(d3.descending)
        .matrix(matrix);

    var width = 550,
        height = 500,
        innerRadius = Math.min(width, height) * .41,
        outerRadius = innerRadius * 1.1;

    var fill = d3.scale.ordinal()
        .domain(d3.range(15))
        .range(chordColors);

    var svg = d3.select("#chordGraph").append("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    svg.append("g").selectAll("path")
        .data(chord.groups)
        .enter().append("path")
        .style("fill", function(d) {
            return fill(d.index);
        })
        .style("stroke", function(d) {
            return fill(d.index);
        })
        .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
        .on("mouseover", fade(.1))
        .on("mouseout", fade(1));

    var ticks = svg.append("g").selectAll("g")
        .data(chord.groups)
        .enter().append("g").selectAll("g")
        .data(groupTicks)
        .enter().append("g")
        .attr("transform", function(d) {
            return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")" + "translate(" + outerRadius + ",0)";
        });

    ticks.append("line")
        .attr("x1", 1)
        .attr("y1", 0)
        .attr("x2", 5)
        .attr("y2", 0)
        .style("stroke", "#000");

    ticks.append("text")
        .attr("x", 8)
        .attr("dy", ".35em")
        .attr("transform", function(d) {
            return d.angle > Math.PI ? "rotate(180)translate(-16)" : null;
        })
        .style("text-anchor", function(d) {
            return d.angle > Math.PI ? "end" : null;
        })
        .text(function(d) {
            return d.label;
        });

    svg.append("g")
        .attr("class", "chord")
        .selectAll("path")
        .data(chord.chords)
        .enter().append("path")
        .attr("d", d3.svg.chord().radius(innerRadius))
        .style("fill", function(d) {
            return fill(d.target.index);
        })
        .style("opacity", 1);

    // Returns an array of tick angles and labels, given a group.
    function groupTicks(d) {
        var k = (d.endAngle - d.startAngle) / d.value;
        return d3.range(0, d.value, 5).map(function(v, i) {
            return {
                angle: v * k + d.startAngle,
                label: v
            };
        });
    }

    // Returns an event handler for fading a given chord group.
    function fade(opacity) {
        return function(g, i) {
            svg.selectAll(".chord path")
                .filter(function(d) {
                    return d.source.index != i && d.target.index != i;
                })
                .transition()
                .style("opacity", opacity);
        };
    }
}

////////////
//////////// Sentiment chart
////////////
var sentimentScores = [];
//get data
for (var i = 0; i < politiker.length; i++) {
    //array to fill, where to look, number
    fillSentimentScores(sentimentScores, politiker, i);
}



function fillSentimentScores(array, politician, number) {
    $.ajax({
        url: "data/Sentiment_scores/" + politician[number] + "-sentimentScores.json",
        dataType: "text",
        success: function(data) {
            var json = $.parseJSON(data);
            var positiveCount = 0;
            var negativeCount = 0;
            var neutralCount = 0;
            $.each(json, function(i, jsonObjectList) {
                //if a value matches from the given json file matches the searchword, add it to the array

                if (jsonObjectList.V1 > 0) {
                    positiveCount++;
                } else if (jsonObjectList.V1 < 0) {
                    negativeCount++;
                } else {
                    neutralCount++;
                }
            });
            sentimentScores.push({
                name: politician[number],
                value: positiveCount,
                value2: negativeCount,
                value3: neutralCount
            });
        }
    });
}


// vent til ajax er ferdig, så kjør!
$(document).ajaxStop(function() {
    makeSentimentChart(sentimentScores, "#sentimentGraph");

    for (var i = 0; i < sentimentScores.length; i++) {
        var tempArray = [];
        if (sentimentScores[i].name == "ernasolberg") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#erna-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#erna-info");
        } else if (sentimentScores[i].name == "audunlysbakken") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#audun-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#audun-info");
        } else if (sentimentScores[i].name == "Siv.Jensen.FrP") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#siv-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#siv-info");
        } else if (sentimentScores[i].name == "bardvegar") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#bard-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#bard-info");
        } else if (sentimentScores[i].name == "dagruneriksen") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#dagrun-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#dagrun-info");
        } else if (sentimentScores[i].name == "geirsp") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#geir-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#geir-info");
        } else if (sentimentScores[i].name == "hanna.e.marcussen") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#hanna-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#hanna-info");
        } else if (sentimentScores[i].name == "JanTSanner") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#jan-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#jan-info");
        } else if (sentimentScores[i].name == "jonasgahrstore") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#jonas-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#jonas-info");
        } else if (sentimentScores[i].name == "Knut.Arild.Hareide") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#knut-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#knut-info");
        } else if (sentimentScores[i].name == "Per.Sandberg.FrP") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#per-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#per-info");
        } else if (sentimentScores[i].name == "rasmusjmhansson") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#rasmus-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#rasmus-info");
        } else if (sentimentScores[i].name == "torbjornroeisaksen") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#torbjorn-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#torbjorn-info");
        } else if (sentimentScores[i].name == "trinesg") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#trine-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#trine-info");
        } else if (sentimentScores[i].name == "UneBastholm") {
            tempArray.push({
                name: sentimentScores[i].name,
                value: sentimentScores[i].value,
                value2: sentimentScores[i].value2
            });
            $("#une-info").append("<h3>Sentiment analyse</h3>");
            makeSentimentChart(tempArray, "#une-info");
        }
    }

    for (var i = 0; i < politikerFulltNavn.length; i++) {
        $("#sentimentNames").append(politikerFulltNavn[i] + ", ");
    }

});

//lag sentimentChart
function makeSentimentChart(sentimentScores, container) {
    data = sentimentScores;

    var margin = {
            top: 30,
            right: 10,
            bottom: 10,
            left: 10
        },
        width = 500 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var x = d3.scale.linear()
        .range([0, width])

    var y = d3.scale.ordinal()
        .rangeRoundBands([0, height], .2);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("top");

    var svg = d3.select(container).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain([-250, 250])
    y.domain(data.map(function(d) {
        return d.name;
    }));

    svg.selectAll(".bar")
        .data(data)
        .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function(d) {
            return x(Math.min(0, d.value));
        })
        .attr("y", function(d) {
            return y(d.name);
        })
        .attr("width", function(d) {
            return Math.abs(x(d.value) - x(0));
        })
        .attr("height", y.rangeBand());

    svg.selectAll(".bar2")
        .data(data)
        .enter().append("rect")
        .attr("class", "bar2")
        .attr("x", function(d) {
            return x(Math.min(0, -d.value2));
        })
        .attr("y", function(d) {
            return y(d.name);
        })
        .attr("width", function(d) {
            return Math.abs(x(-d.value2) - x(0));
        })
        .attr("height", y.rangeBand());




    svg.append("g")
        .attr("class", "x axis")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .append("line")
        .attr("x1", x(0))
        .attr("x2", x(0))
        .attr("y2", height);

    function type(d) {
        d.value = +d.value;
        return d;
    }


}
