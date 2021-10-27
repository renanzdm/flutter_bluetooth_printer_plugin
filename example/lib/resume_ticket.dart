class ResumeTicket {
  static String resumeTicket({Object? obj}) {
    return """
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RECEIPT</title>
</head>

<style>
   @import url('https://fonts.googleapis.com/css?family=Roboto&display=swap');
    body,
    p {
        margin: 0px;
        padding: 0px;
        font-size: large;
    }

    body {
        background: #FFFFFFF;
        width: 576px;
        font-size: 1.8em
    }

    .receipt {
        max-width: 576px;
        margin: auto;
        background: white;
    }

    .container {
        padding: 5px 15px;
        font-family:'Roboto' sans-serif;
    }

    .boldTextTitle {
        font-weight: bold;
        font-size: 2rem;
    }

    .boldTextTitleUpperCase {
        font-weight: bold;
        font-size: 2rem;
        text-transform: uppercase;
    }

    .boldTextSubtitle {
        margin-bottom: 1%;
        font-weight: bold;
        font-size: 1.9rem;
    }

    hr {
        border: 2px dashed black;
        margin-top: 0%;
    }

    .line {
        border: 3px solid #000;
    }

    .text-center {
        text-align: center;
    }

    .text-left {
        text-align: left;
    }

    .text-right {
        text-align: left;
    }

    .text-justify {
        text-align: justify;
    }

    .right {
        float: right;
    }

    .left {
        float: left;
    }

    .total {
        font-size: 2.5em;
        margin: 5px;
    }

    a {
        color: #1976d2;
    }


    span {
        color: black;
        font-size: 24px;
    }

    .full-width {
        width: 100%;
    }

    .inline-block {
        display: inline-block;
    }

    .centerImage {
        display: block;
        margin-left: auto;
        margin-right: auto
    }

    .product {
        margin-bottom: 2%;
    }
</style>

<body>

    <div class="receipt">
        <img class="centerImage"
            src="https://cdn.ecvol.com/s/www.querocase.com.br/produtos/topsocket-ficha-poker-100/z/0.png?v=0"
            width="300" height="300">

        <div class="container">
        
        
        
            <!-- header part -->
            <div class="text-center">
                <p class="boldTextTitle">PokerWeb2</p>
                <p>end</p>
                <span>ci - Paraná</span>
                <br></br>
                <p class="boldTextTitleUpperCase">Resumo Sangeur</p>
                <p class="boldTextSubtitle">usuario</p>
                <span>18/05/2021 - 12:45</span>
            </div>
            <hr class="line">
            <!-- end header part -->
            <!-- product part -->
            
            ${getResumeTable(title: 'testando', titleLine: 'line teste', value: '12,00')}
    
           
           
            
           
           
            <!--end produto -->

            <!-- footer part -->

        </div>
        <!-- end footer part -->
        <div class="container">
            <img class="centerImage"
                src="https://cdn.ecvol.com/s/www.querocase.com.br/produtos/topsocket-ficha-poker-100/z/0.png?v=0"
                width="200" height="200">
        </div>
</body>

</html>
""";
  }

  static String getResumeTable(
      {required String title,
      required String titleLine,
      required String? value}) {
    return """<div class="product">
                <p class="boldTextTitle">$title</p>
                    <p class="full-width inline-block">
                    <span class="left">$titleLine</span>
                    <span class="right">$value</span>
                    <hr>
                     <p class="full-width inline-block">
                     <span class="left">$titleLine</span>
                     <span class="right">$value</span>
                     <hr>
                     <p class="full-width inline-block">
                     <span class="left">$titleLine</span>
                    <span class="right">$value</span>
                    <hr>        
            </div>""";
  }
}
