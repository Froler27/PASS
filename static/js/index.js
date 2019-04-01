function toTest(){
    window.location.href += 'test';
}

window.onload = function (){
    var btnTest = document.getElementById('btnTest');

    btnTest.addEventListener('click', toTest);
}
