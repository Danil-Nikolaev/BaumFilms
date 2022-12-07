var current_url = window.location.href;

if (current_url.indexOf('page=') != -1){
    var current_page = parseInt(current_url.slice(current_url.indexOf('page=') + 5));
}else{
    var current_page = 1;
}

console.log(current_page)

function append_films_for_page() {
    current_page += 1
    const request = $.get(`/films/index.json?current_page=${current_page}`, function(data) {
        for(let index = 0; index < 50; index++){
            
            let countries_text = function () {
                let countries = data[index]['country'];
                let countries_text = 'Жанры: ';
                for (let i = 0; i < countries.length; i++){
                    countries_text += (countries[i]['name_ru'] + ', ');
                }
                return countries_text
            }

            let genres_text = function() {
                let genres = data[index]['genres'];
                let genres_text = 'Жанры: ';
                for(let i = 0; i < genres.length; i++){
                    genres_text += (genres[i]['name_ru'] + ', ');
                }
                return genres_text
            }

            let card_body = $('<div class="card-body">')
            .append(`<h5 class="card-title">${data[index]['name']}</h5>`)
            .append(`<p class="card-text">${countries_text()}</p>`)
            .append(`<p class="card-text">Бюджет: ${data[index]['budget']}</p>`)
            .append(`<p class="card-text">${genres_text()}</p>`)
            .append('<a href="#" class="btn btn-primary">Go somewhere</a>');
            let card = $('<div class="card my-card" style="width: 18rem">')
            .append(`<img class="card-img-top my-card-img" src = ${data[index]['small_poster']}>`)
            .append(card_body);
            $("#films").append(card);
        }
    });
}

$(document).ready(function() {
    $(window).scroll(function() {
        if (jQuery(window).scrollTop() + jQuery(window).height() >= jQuery(document).height()) {
            append_films_for_page();
        }
    })
    $("#btn-acc").on("click", function() {
        let filters_genres  = [];
        let filters_years = [];
        let filters_countries = [];
        let genres_list = $(".genres-class");
        let years_list = $(".years-class");
        let countries_list = $(".countries-class");

        for(let index = 0; index < genres_list.length; index++){
            if (genres_list[index].checked) {
                let str = genres_list[index].nextElementSibling.outerText;
                str = str.trim();
                filters_genres.push(str);
            }
        }

        for(let index = 0; index < years_list.length; index++){
            if (years_list[index].checked) {
                let str = years_list[index].nextElementSibling.outerText;
                str = str.trim();
                filters_years.push(str);
            }
        }

        for(let index = 0; index < countries_list.length; index++){
            if(countries_list[index].checked){
                let str = genres_list[index].nextElementSibling.outerText;
                str = str.trim();
                filters_countries.push(str);
            }
        }
        console.log(filters_genres);
        console.log(filters_years);
        console.log(filters_countries);
        window.location.href= (`/films/index?filters_genres=${filters_genres}&filters_countries=${filters_countries}&filters_years=${filters_years}&current_page=1`);

    })
})