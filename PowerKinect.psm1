  


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>PowerKinect/PowerKinect.psm1 at master · adminian/PowerKinect</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="http://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <link rel="xhr-socket" href="/_sockets">
    <meta name="msapplication-TileImage" content="/windows-tile.png">
    <meta name="msapplication-TileColor" content="#ffffff">

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="3k/78w2+AE7qq8XfPxT7PPbP0gzgUBpGKKOQwFm25a0=" name="csrf-token" />

    <link href="https://a248.e.akamai.net/assets.github.com/assets/github-21d1f919c9b16786238504ad1232b4937bbdd088.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://a248.e.akamai.net/assets.github.com/assets/github2-b702f2bd3370655be3cd89c1cd8cb00052d6a475.css" media="all" rel="stylesheet" type="text/css" />
    


      <script src="https://a248.e.akamai.net/assets.github.com/assets/frameworks-92d138f450f2960501e28397a2f63b0f100590f0.js" type="text/javascript"></script>
      <script src="https://a248.e.akamai.net/assets.github.com/assets/github-8b597885ade82d6a3d9108d93ea8e86b9f294d91.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="77a530946004f4df817ad3a299a913ed">

        <link data-pjax-transient rel='permalink' href='/adminian/PowerKinect/blob/c1c2643817c14fb356d64edc738d660a18b19e76/PowerKinect.psm1'>
    <meta property="og:title" content="PowerKinect"/>
    <meta property="og:type" content="githubog:gitrepository"/>
    <meta property="og:url" content="https://github.com/adminian/PowerKinect"/>
    <meta property="og:image" content="https://secure.gravatar.com/avatar/dfded1047b37a3f24ad248e125f6c1a2?s=420&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"/>
    <meta property="og:site_name" content="GitHub"/>
    <meta property="og:description" content="PowerKinect - Kinect library for PowerShell"/>
    <meta property="twitter:card" content="summary"/>
    <meta property="twitter:site" content="@GitHub">
    <meta property="twitter:title" content="adminian/PowerKinect"/>

    <meta name="description" content="PowerKinect - Kinect library for PowerShell" />

  <link href="https://github.com/adminian/PowerKinect/commits/master.atom" rel="alternate" title="Recent Commits to PowerKinect:master" type="application/atom+xml" />

  </head>


  <body class="logged_in page-blob windows vis-public env-production  ">
    <div id="wrapper">

      

      
      
      

      <div class="header header-logged-in true">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/">
  <span class="mega-icon mega-icon-invertocat"></span>
</a>

    <div class="divider-vertical"></div>

      <a href="/notifications" class="notification-indicator tooltipped downwards" title="You have no unread notifications">
    <span class="mail-status all-read"></span>
  </a>
  <div class="divider-vertical"></div>


      <div class="command-bar js-command-bar  ">
            <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">
  <a href="/search/advanced" class="advanced-search-icon tooltipped downwards command-bar-search" id="advanced_search" title="Advanced search"><span class="mini-icon mini-icon-advanced-search "></span></a>

  <input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" data-username="gyz" autocapitalize="off">

  <span class="mini-icon help tooltipped downwards" title="Show command bar help">
    <span class="mini-icon mini-icon-help"></span>
  </span>

  <input type="hidden" name="ref" value="cmdform">

    <input type="hidden" class="js-repository-name-with-owner" value="adminian/PowerKinect"/>
    <input type="hidden" class="js-repository-branch" value="master"/>
    <input type="hidden" class="js-repository-tree-sha" value="d1c02e2daa111baf4eb68644b75e1c267fcd2726"/>

  <div class="divider-vertical"></div>
</form>
        <ul class="top-nav">
            <li class="explore"><a href="https://github.com/explore">Explore</a></li>
            <li><a href="https://gist.github.com">Gist</a></li>
            <li><a href="/blog">Blog</a></li>
          <li><a href="http://help.github.com">Help</a></li>
        </ul>
      </div>

    

  

    <ul id="user-links">
      <li>
        <a href="https://github.com/gyz" class="name">
          <img height="20" src="https://secure.gravatar.com/avatar/968ccb04c4dc53d9e34c2d4535a5d84d?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="20" /> gyz
        </a>
      </li>

        <li>
          <a href="/new" id="new_repo" class="tooltipped downwards" title="Create a new repo">
            <span class="mini-icon mini-icon-create"></span>
          </a>
        </li>

        <li>
          <a href="/settings/profile" id="account_settings"
            class="tooltipped downwards"
            title="Account settings ">
            <span class="mini-icon mini-icon-account-settings"></span>
          </a>
        </li>
        <li>
          <a class="tooltipped downwards" href="/logout" data-method="post" id="logout" title="Sign out">
            <span class="mini-icon mini-icon-logout"></span>
          </a>
        </li>

    </ul>


<div class="js-new-dropdown-contents hidden">
  <ul class="dropdown-menu">
    <li>
      <a href="/new"><span class="mini-icon mini-icon-create"></span> New repository</a>
    </li>
    <li>
        <a href="https://github.com/adminian/PowerKinect/issues/new"><span class="mini-icon mini-icon-issue-opened"></span> New issue</a>
    </li>
    <li>
    </li>
    <li>
      <a href="/organizations/new"><span class="mini-icon mini-icon-u-list"></span> New organization</a>
    </li>
  </ul>
</div>


    
  </div>
</div>

      

      

      


            <div class="site hfeed" itemscope itemtype="http://schema.org/WebPage">
      <div class="hentry">
        
        <div class="pagehead repohead instapaper_ignore readability-menu ">
          <div class="container">
            <div class="title-actions-bar">
              

<ul class="pagehead-actions">


    <li class="subscription">
      <form accept-charset="UTF-8" action="/notifications/subscribe" data-autosubmit="true" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="3k/78w2+AE7qq8XfPxT7PPbP0gzgUBpGKKOQwFm25a0=" /></div>  <input id="repository_id" name="repository_id" type="hidden" value="4415228" />

    <div class="select-menu js-menu-container js-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">
          <span class="mini-icon mini-icon-watching"></span>
          Watch
        </span>
      </span>

      <div class="select-menu-modal-holder js-menu-content">
        <div class="select-menu-modal">
          <div class="select-menu-header">
            <span class="select-menu-title">Notification status</span>
            <span class="mini-icon mini-icon-remove-close js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-list js-navigation-container">

            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input checked="checked" id="do_included" name="do" type="radio" value="included" />
                <h4>Not watching</h4>
                <span class="description">You only receive notifications for discussions in which you participate or are @mentioned.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-watching"></span>
                  Watch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input id="do_subscribed" name="do" type="radio" value="subscribed" />
                <h4>Watching</h4>
                <span class="description">You receive notifications for all discussions in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-unwatch"></span>
                  Unwatch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input id="do_ignore" name="do" type="radio" value="ignore" />
                <h4>Ignoring</h4>
                <span class="description">You do not receive any notifications for discussions in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-mute"></span>
                  Stop ignoring
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

</form>
    </li>

    <li class="js-toggler-container js-social-container starring-container on">
      <a href="/adminian/PowerKinect/unstar" class="minibutton js-toggler-target star-button starred upwards" title="Unstar this repo" data-remote="true" data-method="post" rel="nofollow">
        <span class="mini-icon mini-icon-remove-star"></span>
        <span class="text">Unstar</span>
      </a>
      <a href="/adminian/PowerKinect/star" class="minibutton js-toggler-target star-button unstarred upwards" title="Star this repo" data-remote="true" data-method="post" rel="nofollow">
        <span class="mini-icon mini-icon-star"></span>
        <span class="text">Star</span>
      </a>
      <a class="social-count js-social-count" href="/adminian/PowerKinect/stargazers">5</a>
    </li>

        <li>
          <a href="/adminian/PowerKinect/fork" class="minibutton js-toggler-target fork-button lighter upwards" title="Fork this repo" rel="nofollow" data-method="post">
            <span class="mini-icon mini-icon-branch-create"></span>
            <span class="text">Fork</span>
          </a>
          <a href="/adminian/PowerKinect/network" class="social-count">0</a>
        </li>


</ul>

              <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
                <span class="repo-label"><span>public</span></span>
                <span class="mega-icon mega-icon-public-repo"></span>
                <span class="author vcard">
                  <a href="/adminian" class="url fn" itemprop="url" rel="author">
                  <span itemprop="title">adminian</span>
                  </a></span> /
                <strong><a href="/adminian/PowerKinect" class="js-current-repository">PowerKinect</a></strong>
              </h1>
            </div>

            
  <ul class="tabs">
    <li class="pulse-nav"><a href="/adminian/PowerKinect/pulse" highlight="pulse" rel="nofollow"><span class="mini-icon mini-icon-pulse"></span></a></li>
    <li><a href="/adminian/PowerKinect" class="selected" highlight="repo_source repo_downloads repo_commits repo_tags repo_branches">Code</a></li>
    <li><a href="/adminian/PowerKinect/network" highlight="repo_network">Network</a></li>
    <li><a href="/adminian/PowerKinect/pulls" highlight="repo_pulls">Pull Requests <span class='counter'>0</span></a></li>

      <li><a href="/adminian/PowerKinect/issues" highlight="repo_issues">Issues <span class='counter'>0</span></a></li>

      <li><a href="/adminian/PowerKinect/wiki" highlight="repo_wiki">Wiki</a></li>


    <li><a href="/adminian/PowerKinect/graphs" highlight="repo_graphs repo_contributors">Graphs</a></li>


  </ul>
  
<div class="tabnav">

  <span class="tabnav-right">
    <ul class="tabnav-tabs">
          <li><a href="/adminian/PowerKinect/tags" class="tabnav-tab" highlight="repo_tags">Tags <span class="counter blank">0</span></a></li>
    </ul>
    
  </span>

  <div class="tabnav-widget scope">


    <div class="select-menu js-menu-container js-select-menu js-branch-menu">
      <a class="minibutton select-menu-button js-menu-target" data-hotkey="w" data-ref="master">
        <span class="mini-icon mini-icon-branch"></span>
        <i>branch:</i>
        <span class="js-select-button">master</span>
      </a>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">

        <div class="select-menu-modal">
          <div class="select-menu-header">
            <span class="select-menu-title">Switch branches/tags</span>
            <span class="mini-icon mini-icon-remove-close js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-filters">
            <div class="select-menu-text-filter">
              <input type="text" id="commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
            </div>
            <div class="select-menu-tabs">
              <ul>
                <li class="select-menu-tab">
                  <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
                </li>
                <li class="select-menu-tab">
                  <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
                </li>
              </ul>
            </div><!-- /.select-menu-tabs -->
          </div><!-- /.select-menu-filters -->

          <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket css-truncate" data-tab-filter="branches">

            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">

                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/adminian/PowerKinect/blob/SDK1.7/PowerKinect.psm1" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="SDK1.7" rel="nofollow" title="SDK1.7">SDK1.7</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item selected">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/adminian/PowerKinect/blob/master/PowerKinect.psm1" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="master" rel="nofollow" title="master">master</a>
                </div> <!-- /.select-menu-item -->
            </div>

              <div class="select-menu-no-results">Nothing to show</div>
          </div> <!-- /.select-menu-list -->


          <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket css-truncate" data-tab-filter="tags">
            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">

            </div>

            <div class="select-menu-no-results">Nothing to show</div>

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

  </div> <!-- /.scope -->

  <ul class="tabnav-tabs">
    <li><a href="/adminian/PowerKinect" class="selected tabnav-tab" highlight="repo_source">Files</a></li>
    <li><a href="/adminian/PowerKinect/commits/master" class="tabnav-tab" highlight="repo_commits">Commits</a></li>
    <li><a href="/adminian/PowerKinect/branches" class="tabnav-tab" highlight="repo_branches" rel="nofollow">Branches <span class="counter ">2</span></a></li>
  </ul>

</div>

  
  
  


            
          </div>
        </div><!-- /.repohead -->

        <div id="js-repo-pjax-container" class="container context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:3259e1cf7e0192a582f0f356907dda47 -->
<!-- blob contrib frag key: views10/v8/blob_contributors:v21:3259e1cf7e0192a582f0f356907dda47 -->


<div id="slider">
    <div class="frame-meta">

      <p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

        <div class="breadcrumb">
          <span class='bold'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/adminian/PowerKinect" class="js-slide-to" data-branch="master" data-direction="back" itemscope="url"><span itemprop="title">PowerKinect</span></a></span></span><span class="separator"> / </span><strong class="final-path">PowerKinect.psm1</strong> <span class="js-zeroclipboard zeroclipboard-button" data-clipboard-text="PowerKinect.psm1" data-copied-hint="copied!" title="copy to clipboard"><span class="mini-icon mini-icon-clipboard"></span></span>
        </div>

      <a href="/adminian/PowerKinect/find/master" class="js-slide-to" data-hotkey="t" style="display:none">Show File Finder</a>


        
  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://secure.gravatar.com/avatar/54b073f96004b6471c4dde100a268b29?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
    <span class="author"><span rel="author">Ian Philpot</span></span>
    <time class="js-relative-date" datetime="2013-04-01T20:46:36-07:00" title="2013-04-01 20:46:36">April 01, 2013</time>
    <div class="commit-title">
        <a href="/adminian/PowerKinect/commit/c1c2643817c14fb356d64edc738d660a18b19e76" class="message">Moved back to Global scope</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong> contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2>Users on GitHub who have contributed to this file</h2>
      <ul class="facebox-user-list">
        <li>
          <img height="24" src="https://secure.gravatar.com/avatar/dfded1047b37a3f24ad248e125f6c1a2?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
          <a href="/adminian">adminian</a>
        </li>
      </ul>
    </div>
  </div>


    </div><!-- ./.frame-meta -->

    <div class="frames">
      <div class="frame" data-permalink-url="/adminian/PowerKinect/blob/c1c2643817c14fb356d64edc738d660a18b19e76/PowerKinect.psm1" data-title="PowerKinect/PowerKinect.psm1 at master · adminian/PowerKinect · GitHub" data-type="blob">

        <div id="files" class="bubble">
          <div class="file">
            <div class="meta">
              <div class="info">
                <span class="icon"><b class="mini-icon mini-icon-text-file"></b></span>
                <span class="mode" title="File Mode">file</span>
                  <span>388 lines (321 sloc)</span>
                <span>11.518 kb</span>
              </div>
              <div class="actions">
                <div class="button-group">
                        <a class="minibutton tooltipped leftwards"
                           title="Clicking this button will automatically fork this project so you can edit the file"
                           href="/adminian/PowerKinect/edit/master/PowerKinect.psm1"
                           data-method="post" rel="nofollow">Edit</a>
                  <a href="/adminian/PowerKinect/raw/master/PowerKinect.psm1" class="button minibutton " id="raw-url">Raw</a>
                    <a href="/adminian/PowerKinect/blame/master/PowerKinect.psm1" class="button minibutton ">Blame</a>
                  <a href="/adminian/PowerKinect/commits/master/PowerKinect.psm1" class="button minibutton " rel="nofollow">History</a>
                </div><!-- /.button-group -->
              </div><!-- /.actions -->

            </div>
                <div class="blob-wrapper data type-powershell js-blob-data">
      <table class="file-code file-diff">
        <tr class="file-code-line">
          <td class="blob-line-nums">
            <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>
<span id="L80" rel="#L80">80</span>
<span id="L81" rel="#L81">81</span>
<span id="L82" rel="#L82">82</span>
<span id="L83" rel="#L83">83</span>
<span id="L84" rel="#L84">84</span>
<span id="L85" rel="#L85">85</span>
<span id="L86" rel="#L86">86</span>
<span id="L87" rel="#L87">87</span>
<span id="L88" rel="#L88">88</span>
<span id="L89" rel="#L89">89</span>
<span id="L90" rel="#L90">90</span>
<span id="L91" rel="#L91">91</span>
<span id="L92" rel="#L92">92</span>
<span id="L93" rel="#L93">93</span>
<span id="L94" rel="#L94">94</span>
<span id="L95" rel="#L95">95</span>
<span id="L96" rel="#L96">96</span>
<span id="L97" rel="#L97">97</span>
<span id="L98" rel="#L98">98</span>
<span id="L99" rel="#L99">99</span>
<span id="L100" rel="#L100">100</span>
<span id="L101" rel="#L101">101</span>
<span id="L102" rel="#L102">102</span>
<span id="L103" rel="#L103">103</span>
<span id="L104" rel="#L104">104</span>
<span id="L105" rel="#L105">105</span>
<span id="L106" rel="#L106">106</span>
<span id="L107" rel="#L107">107</span>
<span id="L108" rel="#L108">108</span>
<span id="L109" rel="#L109">109</span>
<span id="L110" rel="#L110">110</span>
<span id="L111" rel="#L111">111</span>
<span id="L112" rel="#L112">112</span>
<span id="L113" rel="#L113">113</span>
<span id="L114" rel="#L114">114</span>
<span id="L115" rel="#L115">115</span>
<span id="L116" rel="#L116">116</span>
<span id="L117" rel="#L117">117</span>
<span id="L118" rel="#L118">118</span>
<span id="L119" rel="#L119">119</span>
<span id="L120" rel="#L120">120</span>
<span id="L121" rel="#L121">121</span>
<span id="L122" rel="#L122">122</span>
<span id="L123" rel="#L123">123</span>
<span id="L124" rel="#L124">124</span>
<span id="L125" rel="#L125">125</span>
<span id="L126" rel="#L126">126</span>
<span id="L127" rel="#L127">127</span>
<span id="L128" rel="#L128">128</span>
<span id="L129" rel="#L129">129</span>
<span id="L130" rel="#L130">130</span>
<span id="L131" rel="#L131">131</span>
<span id="L132" rel="#L132">132</span>
<span id="L133" rel="#L133">133</span>
<span id="L134" rel="#L134">134</span>
<span id="L135" rel="#L135">135</span>
<span id="L136" rel="#L136">136</span>
<span id="L137" rel="#L137">137</span>
<span id="L138" rel="#L138">138</span>
<span id="L139" rel="#L139">139</span>
<span id="L140" rel="#L140">140</span>
<span id="L141" rel="#L141">141</span>
<span id="L142" rel="#L142">142</span>
<span id="L143" rel="#L143">143</span>
<span id="L144" rel="#L144">144</span>
<span id="L145" rel="#L145">145</span>
<span id="L146" rel="#L146">146</span>
<span id="L147" rel="#L147">147</span>
<span id="L148" rel="#L148">148</span>
<span id="L149" rel="#L149">149</span>
<span id="L150" rel="#L150">150</span>
<span id="L151" rel="#L151">151</span>
<span id="L152" rel="#L152">152</span>
<span id="L153" rel="#L153">153</span>
<span id="L154" rel="#L154">154</span>
<span id="L155" rel="#L155">155</span>
<span id="L156" rel="#L156">156</span>
<span id="L157" rel="#L157">157</span>
<span id="L158" rel="#L158">158</span>
<span id="L159" rel="#L159">159</span>
<span id="L160" rel="#L160">160</span>
<span id="L161" rel="#L161">161</span>
<span id="L162" rel="#L162">162</span>
<span id="L163" rel="#L163">163</span>
<span id="L164" rel="#L164">164</span>
<span id="L165" rel="#L165">165</span>
<span id="L166" rel="#L166">166</span>
<span id="L167" rel="#L167">167</span>
<span id="L168" rel="#L168">168</span>
<span id="L169" rel="#L169">169</span>
<span id="L170" rel="#L170">170</span>
<span id="L171" rel="#L171">171</span>
<span id="L172" rel="#L172">172</span>
<span id="L173" rel="#L173">173</span>
<span id="L174" rel="#L174">174</span>
<span id="L175" rel="#L175">175</span>
<span id="L176" rel="#L176">176</span>
<span id="L177" rel="#L177">177</span>
<span id="L178" rel="#L178">178</span>
<span id="L179" rel="#L179">179</span>
<span id="L180" rel="#L180">180</span>
<span id="L181" rel="#L181">181</span>
<span id="L182" rel="#L182">182</span>
<span id="L183" rel="#L183">183</span>
<span id="L184" rel="#L184">184</span>
<span id="L185" rel="#L185">185</span>
<span id="L186" rel="#L186">186</span>
<span id="L187" rel="#L187">187</span>
<span id="L188" rel="#L188">188</span>
<span id="L189" rel="#L189">189</span>
<span id="L190" rel="#L190">190</span>
<span id="L191" rel="#L191">191</span>
<span id="L192" rel="#L192">192</span>
<span id="L193" rel="#L193">193</span>
<span id="L194" rel="#L194">194</span>
<span id="L195" rel="#L195">195</span>
<span id="L196" rel="#L196">196</span>
<span id="L197" rel="#L197">197</span>
<span id="L198" rel="#L198">198</span>
<span id="L199" rel="#L199">199</span>
<span id="L200" rel="#L200">200</span>
<span id="L201" rel="#L201">201</span>
<span id="L202" rel="#L202">202</span>
<span id="L203" rel="#L203">203</span>
<span id="L204" rel="#L204">204</span>
<span id="L205" rel="#L205">205</span>
<span id="L206" rel="#L206">206</span>
<span id="L207" rel="#L207">207</span>
<span id="L208" rel="#L208">208</span>
<span id="L209" rel="#L209">209</span>
<span id="L210" rel="#L210">210</span>
<span id="L211" rel="#L211">211</span>
<span id="L212" rel="#L212">212</span>
<span id="L213" rel="#L213">213</span>
<span id="L214" rel="#L214">214</span>
<span id="L215" rel="#L215">215</span>
<span id="L216" rel="#L216">216</span>
<span id="L217" rel="#L217">217</span>
<span id="L218" rel="#L218">218</span>
<span id="L219" rel="#L219">219</span>
<span id="L220" rel="#L220">220</span>
<span id="L221" rel="#L221">221</span>
<span id="L222" rel="#L222">222</span>
<span id="L223" rel="#L223">223</span>
<span id="L224" rel="#L224">224</span>
<span id="L225" rel="#L225">225</span>
<span id="L226" rel="#L226">226</span>
<span id="L227" rel="#L227">227</span>
<span id="L228" rel="#L228">228</span>
<span id="L229" rel="#L229">229</span>
<span id="L230" rel="#L230">230</span>
<span id="L231" rel="#L231">231</span>
<span id="L232" rel="#L232">232</span>
<span id="L233" rel="#L233">233</span>
<span id="L234" rel="#L234">234</span>
<span id="L235" rel="#L235">235</span>
<span id="L236" rel="#L236">236</span>
<span id="L237" rel="#L237">237</span>
<span id="L238" rel="#L238">238</span>
<span id="L239" rel="#L239">239</span>
<span id="L240" rel="#L240">240</span>
<span id="L241" rel="#L241">241</span>
<span id="L242" rel="#L242">242</span>
<span id="L243" rel="#L243">243</span>
<span id="L244" rel="#L244">244</span>
<span id="L245" rel="#L245">245</span>
<span id="L246" rel="#L246">246</span>
<span id="L247" rel="#L247">247</span>
<span id="L248" rel="#L248">248</span>
<span id="L249" rel="#L249">249</span>
<span id="L250" rel="#L250">250</span>
<span id="L251" rel="#L251">251</span>
<span id="L252" rel="#L252">252</span>
<span id="L253" rel="#L253">253</span>
<span id="L254" rel="#L254">254</span>
<span id="L255" rel="#L255">255</span>
<span id="L256" rel="#L256">256</span>
<span id="L257" rel="#L257">257</span>
<span id="L258" rel="#L258">258</span>
<span id="L259" rel="#L259">259</span>
<span id="L260" rel="#L260">260</span>
<span id="L261" rel="#L261">261</span>
<span id="L262" rel="#L262">262</span>
<span id="L263" rel="#L263">263</span>
<span id="L264" rel="#L264">264</span>
<span id="L265" rel="#L265">265</span>
<span id="L266" rel="#L266">266</span>
<span id="L267" rel="#L267">267</span>
<span id="L268" rel="#L268">268</span>
<span id="L269" rel="#L269">269</span>
<span id="L270" rel="#L270">270</span>
<span id="L271" rel="#L271">271</span>
<span id="L272" rel="#L272">272</span>
<span id="L273" rel="#L273">273</span>
<span id="L274" rel="#L274">274</span>
<span id="L275" rel="#L275">275</span>
<span id="L276" rel="#L276">276</span>
<span id="L277" rel="#L277">277</span>
<span id="L278" rel="#L278">278</span>
<span id="L279" rel="#L279">279</span>
<span id="L280" rel="#L280">280</span>
<span id="L281" rel="#L281">281</span>
<span id="L282" rel="#L282">282</span>
<span id="L283" rel="#L283">283</span>
<span id="L284" rel="#L284">284</span>
<span id="L285" rel="#L285">285</span>
<span id="L286" rel="#L286">286</span>
<span id="L287" rel="#L287">287</span>
<span id="L288" rel="#L288">288</span>
<span id="L289" rel="#L289">289</span>
<span id="L290" rel="#L290">290</span>
<span id="L291" rel="#L291">291</span>
<span id="L292" rel="#L292">292</span>
<span id="L293" rel="#L293">293</span>
<span id="L294" rel="#L294">294</span>
<span id="L295" rel="#L295">295</span>
<span id="L296" rel="#L296">296</span>
<span id="L297" rel="#L297">297</span>
<span id="L298" rel="#L298">298</span>
<span id="L299" rel="#L299">299</span>
<span id="L300" rel="#L300">300</span>
<span id="L301" rel="#L301">301</span>
<span id="L302" rel="#L302">302</span>
<span id="L303" rel="#L303">303</span>
<span id="L304" rel="#L304">304</span>
<span id="L305" rel="#L305">305</span>
<span id="L306" rel="#L306">306</span>
<span id="L307" rel="#L307">307</span>
<span id="L308" rel="#L308">308</span>
<span id="L309" rel="#L309">309</span>
<span id="L310" rel="#L310">310</span>
<span id="L311" rel="#L311">311</span>
<span id="L312" rel="#L312">312</span>
<span id="L313" rel="#L313">313</span>
<span id="L314" rel="#L314">314</span>
<span id="L315" rel="#L315">315</span>
<span id="L316" rel="#L316">316</span>
<span id="L317" rel="#L317">317</span>
<span id="L318" rel="#L318">318</span>
<span id="L319" rel="#L319">319</span>
<span id="L320" rel="#L320">320</span>
<span id="L321" rel="#L321">321</span>
<span id="L322" rel="#L322">322</span>
<span id="L323" rel="#L323">323</span>
<span id="L324" rel="#L324">324</span>
<span id="L325" rel="#L325">325</span>
<span id="L326" rel="#L326">326</span>
<span id="L327" rel="#L327">327</span>
<span id="L328" rel="#L328">328</span>
<span id="L329" rel="#L329">329</span>
<span id="L330" rel="#L330">330</span>
<span id="L331" rel="#L331">331</span>
<span id="L332" rel="#L332">332</span>
<span id="L333" rel="#L333">333</span>
<span id="L334" rel="#L334">334</span>
<span id="L335" rel="#L335">335</span>
<span id="L336" rel="#L336">336</span>
<span id="L337" rel="#L337">337</span>
<span id="L338" rel="#L338">338</span>
<span id="L339" rel="#L339">339</span>
<span id="L340" rel="#L340">340</span>
<span id="L341" rel="#L341">341</span>
<span id="L342" rel="#L342">342</span>
<span id="L343" rel="#L343">343</span>
<span id="L344" rel="#L344">344</span>
<span id="L345" rel="#L345">345</span>
<span id="L346" rel="#L346">346</span>
<span id="L347" rel="#L347">347</span>
<span id="L348" rel="#L348">348</span>
<span id="L349" rel="#L349">349</span>
<span id="L350" rel="#L350">350</span>
<span id="L351" rel="#L351">351</span>
<span id="L352" rel="#L352">352</span>
<span id="L353" rel="#L353">353</span>
<span id="L354" rel="#L354">354</span>
<span id="L355" rel="#L355">355</span>
<span id="L356" rel="#L356">356</span>
<span id="L357" rel="#L357">357</span>
<span id="L358" rel="#L358">358</span>
<span id="L359" rel="#L359">359</span>
<span id="L360" rel="#L360">360</span>
<span id="L361" rel="#L361">361</span>
<span id="L362" rel="#L362">362</span>
<span id="L363" rel="#L363">363</span>
<span id="L364" rel="#L364">364</span>
<span id="L365" rel="#L365">365</span>
<span id="L366" rel="#L366">366</span>
<span id="L367" rel="#L367">367</span>
<span id="L368" rel="#L368">368</span>
<span id="L369" rel="#L369">369</span>
<span id="L370" rel="#L370">370</span>
<span id="L371" rel="#L371">371</span>
<span id="L372" rel="#L372">372</span>
<span id="L373" rel="#L373">373</span>
<span id="L374" rel="#L374">374</span>
<span id="L375" rel="#L375">375</span>
<span id="L376" rel="#L376">376</span>
<span id="L377" rel="#L377">377</span>
<span id="L378" rel="#L378">378</span>
<span id="L379" rel="#L379">379</span>
<span id="L380" rel="#L380">380</span>
<span id="L381" rel="#L381">381</span>
<span id="L382" rel="#L382">382</span>
<span id="L383" rel="#L383">383</span>
<span id="L384" rel="#L384">384</span>
<span id="L385" rel="#L385">385</span>
<span id="L386" rel="#L386">386</span>
<span id="L387" rel="#L387">387</span>
<span id="L388" rel="#L388">388</span>

          </td>
          <td class="blob-line-code">
                  <div class="highlight"><pre><div class='line' id='LC1'><span class="c">###################################################</span></div><div class='line' id='LC2'><span class="c">###################################################</span></div><div class='line' id='LC3'><span class="c"># Variables that are editable</span></div><div class='line' id='LC4'><br/></div><div class='line' id='LC5'><span class="c">#hashtable that defines what can be recognized speech</span></div><div class='line' id='LC6'><span class="c">#use either string code or a keystroke in curly braces</span></div><div class='line' id='LC7'><span class="nv">$Global:PwrGrammartoAdd</span> <span class="p">=</span> <span class="err">@</span><span class="p">{</span></div><div class='line' id='LC8'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;dir&#39;</span> <span class="p">=</span> <span class="s1">&#39;Get-ChildItem c:\&#39;</span></div><div class='line' id='LC9'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;directory&#39;</span> <span class="p">=</span> <span class="s1">&#39;Get-ChildItem c:\&#39;</span></div><div class='line' id='LC10'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;Get Childitem&#39;</span> <span class="p">=</span> <span class="s1">&#39;Get-Childitem c:\&#39;</span></div><div class='line' id='LC11'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;Processes&#39;</span> <span class="p">=</span> <span class="s1">&#39;Get-Process&#39;</span></div><div class='line' id='LC12'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;clear&#39;</span> <span class="p">=</span> <span class="s1">&#39;cls&#39;</span></div><div class='line' id='LC13'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;notepad&#39;</span> <span class="p">=</span> <span class="s1">&#39;notepad&#39;</span></div><div class='line' id='LC14'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;calc&#39;</span> <span class="p">=</span> <span class="s1">&#39;calc&#39;</span></div><div class='line' id='LC15'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;Stop Kinect&#39;</span> <span class="p">=</span> <span class="s1">&#39;&#39;</span>    </div><div class='line' id='LC16'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;BACKSPACE&#39;</span> <span class="p">=</span> <span class="s1">&#39;{BACKSPACE}&#39;</span></div><div class='line' id='LC17'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;BREAK&#39;</span> <span class="p">=</span> <span class="s1">&#39;{BREAK} &#39;</span></div><div class='line' id='LC18'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;CAPS LOCK&#39;</span> <span class="p">=</span> <span class="s1">&#39;{CAPSLOCK}&#39;</span></div><div class='line' id='LC19'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;DEL or DELETE&#39;</span> <span class="p">=</span> <span class="s1">&#39;{DELETE}&#39;</span></div><div class='line' id='LC20'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;DOWN ARROW&#39;</span> <span class="p">=</span> <span class="s1">&#39;{DOWN}&#39;</span></div><div class='line' id='LC21'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;END&#39;</span> <span class="p">=</span> <span class="s1">&#39;{END}&#39;</span></div><div class='line' id='LC22'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;ENTER&#39;</span> <span class="p">=</span> <span class="s1">&#39;{ENTER}&#39;</span></div><div class='line' id='LC23'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;ESC&#39;</span> <span class="p">=</span> <span class="s1">&#39;{ESC}&#39;</span></div><div class='line' id='LC24'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;HELP&#39;</span> <span class="p">=</span> <span class="s1">&#39;{HELP}&#39;</span></div><div class='line' id='LC25'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;HOME&#39;</span> <span class="p">=</span> <span class="s1">&#39;{HOME}&#39;</span></div><div class='line' id='LC26'><span class="c">#    &#39;INS&#39; = &#39;{INS}&#39;</span></div><div class='line' id='LC27'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;INSERT&#39;</span> <span class="p">=</span> <span class="s1">&#39;{INSERT}&#39;</span></div><div class='line' id='LC28'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;LEFT ARROW&#39;</span> <span class="p">=</span> <span class="s1">&#39;{LEFT}&#39;</span></div><div class='line' id='LC29'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;NUM LOCK&#39;</span> <span class="p">=</span> <span class="s1">&#39;{NUMLOCK}&#39;</span> </div><div class='line' id='LC30'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;PAGE DOWN&#39;</span> <span class="p">=</span> <span class="s1">&#39;{PGDN} &#39;</span></div><div class='line' id='LC31'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;PAGE UP&#39;</span> <span class="p">=</span> <span class="s1">&#39;{PGUP} &#39;</span></div><div class='line' id='LC32'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;PRINT SCREEN&#39;</span> <span class="p">=</span> <span class="s1">&#39;{PRTSC}&#39;</span></div><div class='line' id='LC33'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;RIGHT ARROW&#39;</span> <span class="p">=</span> <span class="s1">&#39;{RIGHT}&#39;</span></div><div class='line' id='LC34'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;SCROLL LOCK&#39;</span> <span class="p">=</span> <span class="s1">&#39;{SCROLLLOCK}&#39;</span></div><div class='line' id='LC35'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;TAB&#39;</span> <span class="p">=</span> <span class="s1">&#39;{TAB}&#39;</span></div><div class='line' id='LC36'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;UP ARROW&#39;</span> <span class="p">=</span> <span class="s1">&#39;{UP}&#39;</span></div><div class='line' id='LC37'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="s1">&#39;Alt Tab&#39;</span> <span class="p">=</span> <span class="s1">&#39;{%{TAB}}&#39;</span></div><div class='line' id='LC38'><span class="c">#    &#39;F1&#39; = &#39;{F1}&#39;</span></div><div class='line' id='LC39'><span class="c">#    &#39;F2&#39; = &#39;{F2}&#39;</span></div><div class='line' id='LC40'><span class="c">#    &#39;F3&#39; = &#39;{F3}&#39;</span></div><div class='line' id='LC41'><span class="c">#    &#39;F4&#39; = &#39;{F4}&#39;</span></div><div class='line' id='LC42'><span class="c">#    &#39;F5&#39; = &#39;{F5}&#39;</span></div><div class='line' id='LC43'><span class="c">#    &#39;F6&#39; = &#39;{F6}&#39;</span></div><div class='line' id='LC44'><span class="c">#    &#39;F7&#39; = &#39;{F7}&#39;</span></div><div class='line' id='LC45'><span class="c">#    &#39;F8&#39; = &#39;{F8}&#39;</span></div><div class='line' id='LC46'><span class="c">#    &#39;F9&#39; = &#39;{F9}&#39;</span></div><div class='line' id='LC47'><span class="c">#    &#39;F10&#39; = &#39;{F10}&#39; </span></div><div class='line' id='LC48'><span class="c">#    &#39;F11&#39; = &#39;{F11}&#39;</span></div><div class='line' id='LC49'><span class="c">#    &#39;F12&#39; = &#39;{F12}&#39;</span></div><div class='line' id='LC50'><span class="c">#    &#39;F13&#39; = &#39;{F13}&#39;</span></div><div class='line' id='LC51'><span class="c">#    &#39;F14&#39; = &#39;{F14}&#39;</span></div><div class='line' id='LC52'><span class="c">#    &#39;F15&#39; = &#39;{F15}&#39;</span></div><div class='line' id='LC53'><span class="c">#    &#39;F16&#39; = &#39;{F16}&#39;</span></div><div class='line' id='LC54'><span class="c">#    &#39;Keypad add&#39; = &#39;{ADD}&#39;</span></div><div class='line' id='LC55'><span class="c">#    &#39;Keypad subtract&#39; = &#39;{SUBTRACT}&#39;</span></div><div class='line' id='LC56'><span class="c">#    &#39;Keypad multiply&#39; = &#39;{MULTIPLY}&#39;</span></div><div class='line' id='LC57'><span class="c">#    &#39;Keypad divide&#39; = &#39;{DIVIDE}&#39;</span></div><div class='line' id='LC58'><span class="c">#    &#39;under score&#39; = &#39;{_}&#39;</span></div><div class='line' id='LC59'><span class="c">#    &#39;under bar&#39; = &#39;{_}&#39;</span></div><div class='line' id='LC60'><span class="c">#    &#39;pipe&#39; = &#39;{ | }&#39;</span></div><div class='line' id='LC61'><span class="c">#    &#39;pipeline&#39; = &#39;{ | }&#39;</span></div><div class='line' id='LC62'><span class="c">#    &#39;space&#39; = &#39;{ }&#39;</span></div><div class='line' id='LC63'><span class="c">#    &#39;a&#39; = &#39;{a}&#39;</span></div><div class='line' id='LC64'><span class="c">#    &#39;b&#39; = &#39;{b}&#39;</span></div><div class='line' id='LC65'><span class="c">#    &#39;c&#39; = &#39;{c}&#39;</span></div><div class='line' id='LC66'><span class="c">#    &#39;d&#39; = &#39;{d}&#39;</span></div><div class='line' id='LC67'><span class="c">#    &#39;e&#39; = &#39;{e}&#39;</span></div><div class='line' id='LC68'><span class="c">#    &#39;f&#39; = &#39;{f}&#39;</span></div><div class='line' id='LC69'><span class="c">#    &#39;g&#39; = &#39;{g}&#39;</span></div><div class='line' id='LC70'><span class="c">#    &#39;h&#39; = &#39;{h}&#39;</span></div><div class='line' id='LC71'><span class="c">#    &#39;i&#39; = &#39;{i}&#39;</span></div><div class='line' id='LC72'><span class="c">#    &#39;j&#39; = &#39;{j}&#39;</span></div><div class='line' id='LC73'><span class="c">#    &#39;k&#39; = &#39;{k}&#39;</span></div><div class='line' id='LC74'><span class="c">#    &#39;l&#39; = &#39;{l}&#39;</span></div><div class='line' id='LC75'><span class="c">#    &#39;m&#39; = &#39;{m}&#39;</span></div><div class='line' id='LC76'><span class="c">#    &#39;n&#39; = &#39;{n}&#39;</span></div><div class='line' id='LC77'><span class="c">#    &#39;o&#39; = &#39;{o}&#39;</span></div><div class='line' id='LC78'><span class="c">#    &#39;p&#39; = &#39;{p}&#39;</span></div><div class='line' id='LC79'><span class="c">#    &#39;q&#39; = &#39;{q}&#39;</span></div><div class='line' id='LC80'><span class="c">#    &#39;r&#39; = &#39;{a}&#39;</span></div><div class='line' id='LC81'><span class="c">#    &#39;s&#39; = &#39;{s}&#39;</span></div><div class='line' id='LC82'><span class="c">#    &#39;t&#39; = &#39;{t}&#39;</span></div><div class='line' id='LC83'><span class="c">#    &#39;u&#39; = &#39;{u}&#39;</span></div><div class='line' id='LC84'><span class="c">#    &#39;v&#39; = &#39;{v}&#39;</span></div><div class='line' id='LC85'><span class="c">#    &#39;w&#39; = &#39;{w}&#39;</span></div><div class='line' id='LC86'><span class="c">#    &#39;x&#39; = &#39;{x}&#39;</span></div><div class='line' id='LC87'><span class="c">#    &#39;y&#39; = &#39;{y}&#39;</span></div><div class='line' id='LC88'><span class="c">#    &#39;z&#39; = &#39;{z}&#39;</span></div><div class='line' id='LC89'><span class="c">#    &#39;1&#39; = &#39;{1}&#39;</span></div><div class='line' id='LC90'><span class="c">#    &#39;2&#39; = &#39;{2}&#39;</span></div><div class='line' id='LC91'><span class="c">#    &#39;3&#39; = &#39;{3}&#39;</span></div><div class='line' id='LC92'><span class="c">#    &#39;4&#39; = &#39;{4}&#39;</span></div><div class='line' id='LC93'><span class="c">#    &#39;5&#39; = &#39;{5}&#39;</span></div><div class='line' id='LC94'><span class="c">#    &#39;6&#39; = &#39;{6}&#39;</span></div><div class='line' id='LC95'><span class="c">#    &#39;7&#39; = &#39;{7}&#39;</span></div><div class='line' id='LC96'><span class="c">#    &#39;8&#39; = &#39;{8}&#39;</span></div><div class='line' id='LC97'><span class="c">#    &#39;9&#39; = &#39;{9}&#39;</span></div><div class='line' id='LC98'><span class="c">#    &#39;0&#39; = &#39;{0}&#39;</span></div><div class='line' id='LC99'><br/></div><div class='line' id='LC100'>&nbsp;<span class="p">}</span></div><div class='line' id='LC101'><br/></div><div class='line' id='LC102'><span class="c">#Threshold which we think we understand what was said</span></div><div class='line' id='LC103'><span class="c">#likely leave this alone unless you get a lot of false</span></div><div class='line' id='LC104'><span class="c">#positives and you could turn it up slightly</span></div><div class='line' id='LC105'><span class="nv">$Global:PwrConfidenceThreshold</span> <span class="p">=</span> <span class="n">0</span><span class="p">.</span><span class="n">3</span></div><div class='line' id='LC106'><br/></div><div class='line' id='LC107'><span class="c">#This is cosmetic and need never be changed</span></div><div class='line' id='LC108'><span class="nv">$Global:PwrEventsourceName</span> <span class="p">=</span> <span class="s1">&#39;Speech Recognition Event&#39;</span></div><div class='line' id='LC109'><br/></div><div class='line' id='LC110'><span class="c">###################################################</span></div><div class='line' id='LC111'><span class="c">###################################################</span></div><div class='line' id='LC112'><br/></div><div class='line' id='LC113'><span class="k">function</span> <span class="nb">Add-KinectType</span> <span class="p">{</span></div><div class='line' id='LC114'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-Type</span> <span class="n">-Path</span> <span class="s2">&quot;C:\Program Files\Microsoft SDKs\Kinect\v1.6\Assemblies\Microsoft.Kinect.dll&quot;</span></div><div class='line' id='LC115'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-Type</span> <span class="n">-Path</span> <span class="s2">&quot;C:\Program Files\Microsoft SDKs\Kinect\Developer Toolkit v1.6.0\Samples\bin\Microsoft.Kinect.Toolkit.dll&quot;</span></div><div class='line' id='LC116'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-Type</span> <span class="n">-Path</span> <span class="s2">&quot;C:\Program Files\Microsoft SDKs\Kinect\Developer Toolkit v1.6.0\Samples\bin\Microsoft.Samples.Kinect.SwipeGestureRecognizer.dll&quot;</span></div><div class='line' id='LC117'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-Type</span> <span class="n">-AssemblyName</span> <span class="s1">&#39;microsoft.speech, Version=11.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35&#39;</span></div><div class='line' id='LC118'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-Type</span> <span class="n">-AssemblyName</span> <span class="s1">&#39;system.windows.forms&#39;</span></div><div class='line' id='LC119'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[Microsoft.Kinect.KinectSensor]</span><span class="nv">$Global:PwrKinect</span></div><div class='line' id='LC120'><span class="p">}</span></div><div class='line' id='LC121'><br/></div><div class='line' id='LC122'><span class="k">function</span> <span class="nb">Start-Kinect</span> <span class="p">{</span></div><div class='line' id='LC123'><br/></div><div class='line' id='LC124'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-KinectType</span></div><div class='line' id='LC125'><br/></div><div class='line' id='LC126'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$kinectSensors</span> <span class="p">=</span> <span class="no">[Microsoft.Kinect.KinectSensor]</span><span class="err">::</span><span class="n">KinectSensors</span></div><div class='line' id='LC127'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrActiveRecognizer</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Samples</span><span class="p">.</span><span class="n">Kinect</span><span class="p">.</span><span class="n">SwipeGestureRecognizer</span><span class="p">.</span><span class="n">Recognizer</span></div><div class='line' id='LC128'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrNearestId</span> <span class="p">=</span> <span class="p">-</span><span class="n">1</span></div><div class='line' id='LC129'><br/></div><div class='line' id='LC130'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">try</span> <span class="p">{</span></div><div class='line' id='LC131'><br/></div><div class='line' id='LC132'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">foreach</span> <span class="p">(</span><span class="nv">$k</span> <span class="k">in</span> <span class="nv">$kinectSensors</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC133'><br/></div><div class='line' id='LC134'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$k</span><span class="p">.</span><span class="n">Status</span> <span class="o">-eq</span> <span class="no">[Microsoft.Kinect.KinectStatus]</span><span class="err">::</span><span class="n">Connected</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC135'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span> <span class="p">=</span> <span class="nv">$k</span></div><div class='line' id='LC136'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Host</span> <span class="s2">&quot;Kinect found!&quot;</span> <span class="n">-ForegroundColor</span> <span class="n">Yellow</span></div><div class='line' id='LC137'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC138'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC139'><br/></div><div class='line' id='LC140'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$kinectSensors</span><span class="p">.</span><span class="n">Count</span> <span class="o">-eq</span> <span class="n">0</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC141'><br/></div><div class='line' id='LC142'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Host</span> <span class="s2">&quot;No Sensor found...&quot;</span> <span class="n">-ForegroundColor</span> <span class="n">Yellow</span></div><div class='line' id='LC143'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC144'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span> <span class="p">{</span></div><div class='line' id='LC145'><br/></div><div class='line' id='LC146'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrKinect</span> <span class="o">-eq</span> <span class="nv">$null</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC147'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span><span class="err">;</span></div><div class='line' id='LC148'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC149'><br/></div><div class='line' id='LC150'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">Start</span><span class="p">()</span></div><div class='line' id='LC151'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Host</span> <span class="s2">&quot;Kinect Started!&quot;</span> <span class="n">-ForegroundColor</span> <span class="n">Yellow</span></div><div class='line' id='LC152'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC153'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span> </div><div class='line' id='LC154'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">catch</span> <span class="p">{</span></div><div class='line' id='LC155'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-host</span> <span class="nv">$Error</span><span class="p">[</span><span class="n">0</span><span class="p">].</span><span class="n">Exception</span><span class="p">.</span><span class="n">Message</span> <span class="n">-ForegroundColor</span> <span class="n">Red</span></div><div class='line' id='LC156'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$error</span><span class="p">.</span><span class="n">Clear</span><span class="p">()</span></div><div class='line' id='LC157'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC158'><span class="p">}</span></div><div class='line' id='LC159'><br/></div><div class='line' id='LC160'><span class="k">function</span> <span class="nb">Stop-Kinect</span> <span class="p">{</span></div><div class='line' id='LC161'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrKinect</span> <span class="o">-eq</span> <span class="nv">$null</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC162'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span><span class="err">;</span></div><div class='line' id='LC163'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC164'><br/></div><div class='line' id='LC165'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">Stop</span><span class="p">()</span></div><div class='line' id='LC166'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Host</span> <span class="s2">&quot;Kinect Stopped!&quot;</span> <span class="n">-ForegroundColor</span> <span class="n">Yellow</span></div><div class='line' id='LC167'><span class="p">}</span></div><div class='line' id='LC168'><br/></div><div class='line' id='LC169'><span class="k">function</span> <span class="nb">Enable-ColorStream</span> <span class="p">{</span></div><div class='line' id='LC170'><br/></div><div class='line' id='LC171'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC172'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC173'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC174'><br/></div><div class='line' id='LC175'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">ColorStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC176'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">ColorStream</span><span class="p">.</span><span class="n">Enable</span><span class="p">()</span></div><div class='line' id='LC177'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC178'><span class="p">}</span></div><div class='line' id='LC179'><br/></div><div class='line' id='LC180'><span class="k">function</span> <span class="nb">Disable-ColorStream</span> <span class="p">{</span></div><div class='line' id='LC181'>&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC182'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">ColorStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC183'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">ColorStream</span><span class="p">.</span><span class="n">Disable</span><span class="p">()</span></div><div class='line' id='LC184'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC185'><span class="p">}</span></div><div class='line' id='LC186'><br/></div><div class='line' id='LC187'><span class="k">function</span> <span class="nb">Enable-DepthStream</span> <span class="p">{</span></div><div class='line' id='LC188'><br/></div><div class='line' id='LC189'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">DepthStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC190'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">DepthStream</span><span class="p">.</span><span class="n">Enable</span><span class="p">()</span></div><div class='line' id='LC191'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC192'><span class="p">}</span></div><div class='line' id='LC193'><br/></div><div class='line' id='LC194'><span class="k">function</span> <span class="nb">Disable-DepthStream</span> <span class="p">{</span></div><div class='line' id='LC195'><br/></div><div class='line' id='LC196'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">DepthStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC197'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">DepthStream</span><span class="p">.</span><span class="n">Disable</span><span class="p">()</span></div><div class='line' id='LC198'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC199'><span class="p">}</span></div><div class='line' id='LC200'><br/></div><div class='line' id='LC201'><span class="k">function</span> <span class="nb">Enable-SkeletonStream</span> <span class="p">{</span></div><div class='line' id='LC202'><br/></div><div class='line' id='LC203'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC204'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC205'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC206'><br/></div><div class='line' id='LC207'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC208'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Register-ObjectEvent</span> <span class="n">-InputObject</span> <span class="nv">$Global:PwrKinect</span> <span class="n">-EventName</span> <span class="n">SkeletonFrameReady</span> <span class="n">-SourceIdentifier</span> <span class="n">FrameReady</span> <span class="n">-Action</span> <span class="p">{</span></div><div class='line' id='LC209'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$frame</span> <span class="p">=</span> <span class="nv">$Event</span><span class="p">.</span><span class="n">SourceArgs</span><span class="p">[</span><span class="n">1</span><span class="p">].</span><span class="n">OpenSkeletonFrame</span><span class="p">()</span></div><div class='line' id='LC210'><br/></div><div class='line' id='LC211'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$frame</span> <span class="o">-ne</span> <span class="nv">$null</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC212'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[Microsoft.Kinect.Skeleton[]]</span><span class="nv">$skeletons</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Kinect</span><span class="p">.</span><span class="n">Skeleton</span><span class="p">[]</span> <span class="nv">$frame</span><span class="p">.</span><span class="n">SkeletonArrayLength</span></div><div class='line' id='LC213'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$frame</span><span class="p">.</span><span class="n">CopySkeletonDataTo</span><span class="p">(</span><span class="nv">$skeletons</span><span class="p">)</span></div><div class='line' id='LC214'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$newNearestId</span> <span class="p">=</span> <span class="p">-</span><span class="n">1</span></div><div class='line' id='LC215'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$nearestDistance2</span> <span class="p">=</span> <span class="no">[System.Double]</span><span class="err">::</span><span class="n">MaxValue</span></div><div class='line' id='LC216'><br/></div><div class='line' id='LC217'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">foreach</span> <span class="p">(</span><span class="nv">$skeleton</span> <span class="k">in</span> <span class="nv">$skeletons</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC218'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$skeleton</span><span class="p">.</span><span class="n">TrackingState</span> <span class="o">-eq</span> <span class="no">[Microsoft.Kinect.SkeletonTrackingState]</span><span class="err">::</span><span class="n">Tracked</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC219'><br/></div><div class='line' id='LC220'><br/></div><div class='line' id='LC221'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$distance2</span> <span class="p">=</span> <span class="p">(</span><span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">X</span> <span class="p">*</span> <span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">Y</span><span class="p">)</span> <span class="p">+</span> <span class="p">(</span><span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">Y</span> <span class="p">*</span> <span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">Y</span><span class="p">)</span> <span class="p">+</span> <span class="p">(</span><span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">X</span> <span class="p">*</span> <span class="nv">$skeleton</span><span class="p">.</span><span class="k">Position</span><span class="p">.</span><span class="n">X</span><span class="p">)</span></div><div class='line' id='LC222'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$distance2</span> <span class="o">-lt</span> <span class="nv">$nearestDistance2</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC223'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$newNearestId</span> <span class="p">=</span> <span class="nv">$skeleton</span><span class="p">.</span><span class="n">TrackingId</span></div><div class='line' id='LC224'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$nearestDistance2</span> <span class="p">=</span> <span class="nv">$distance2</span></div><div class='line' id='LC225'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC226'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrActiveRecognizer</span><span class="p">.</span><span class="n">Recognize</span><span class="p">(</span><span class="nv">$sender</span><span class="p">,</span> <span class="nv">$frame</span><span class="p">,</span> <span class="nv">$skeletons</span><span class="p">)</span></div><div class='line' id='LC227'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC228'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC229'><br/></div><div class='line' id='LC230'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrNearestId</span> <span class="o">-ne</span> <span class="nv">$newNearestId</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC231'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrNearestId</span> <span class="p">=</span> <span class="nv">$newNearestId</span></div><div class='line' id='LC232'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC233'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC234'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span><span class="c">#END IF #&gt;</span></div><div class='line' id='LC235'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC236'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">Enable</span><span class="p">()</span></div><div class='line' id='LC237'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC238'><span class="p">}</span></div><div class='line' id='LC239'><br/></div><div class='line' id='LC240'><span class="k">function</span> <span class="nb">Disable-SkeletonStream</span> <span class="p">{</span></div><div class='line' id='LC241'>&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC242'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC243'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">Disable</span><span class="p">()</span></div><div class='line' id='LC244'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC245'><br/></div><div class='line' id='LC246'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="c">#Need to Unregister Events and Remove Jobs</span></div><div class='line' id='LC247'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$evtSubscriber</span> <span class="p">=</span> <span class="nb">Get-EventSubscriber</span></div><div class='line' id='LC248'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-EventSubscriber</span> <span class="n">RightHand</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Unregister-Event</span></div><div class='line' id='LC249'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-EventSubscriber</span> <span class="n">LeftHand</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Unregister-Event</span> </div><div class='line' id='LC250'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-EventSubscriber</span> <span class="n">FrameReady</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Unregister-Event</span></div><div class='line' id='LC251'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-Job</span> <span class="n">RightHand</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Remove-Job</span></div><div class='line' id='LC252'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-Job</span> <span class="n">LeftHand</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Remove-Job</span></div><div class='line' id='LC253'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Get-Job</span> <span class="n">FrameReady</span> <span class="n">-ErrorAction</span> <span class="n">SilentlyContinue</span> <span class="p">|</span> <span class="nb">Remove-Job</span></div><div class='line' id='LC254'><span class="p">}</span></div><div class='line' id='LC255'><br/></div><div class='line' id='LC256'><span class="k">function</span> <span class="nb">Add-RightHandGesture</span> <span class="p">{</span></div><div class='line' id='LC257'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">param</span> <span class="p">(</span><span class="nv">$action</span><span class="p">)</span></div><div class='line' id='LC258'>&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC259'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC260'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC261'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC262'><br/></div><div class='line' id='LC263'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC264'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Enable-SkeletonStream</span></div><div class='line' id='LC265'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC266'><br/></div><div class='line' id='LC267'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Register-ObjectEvent</span> <span class="n">-InputObject</span> <span class="nv">$Global:PwrActiveRecognizer</span> <span class="n">-EventName</span> <span class="n">SwipeRightDetected</span> <span class="n">-SourceIdentifier</span> <span class="n">RightHand</span> <span class="n">-Action</span> <span class="nv">$action</span> </div><div class='line' id='LC268'><span class="p">}</span></div><div class='line' id='LC269'><br/></div><div class='line' id='LC270'><span class="k">function</span> <span class="nb">Add-LeftHandGesture</span> <span class="p">{</span></div><div class='line' id='LC271'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">param</span> <span class="p">(</span><span class="nv">$action</span><span class="p">)</span></div><div class='line' id='LC272'>&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC273'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC274'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC275'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC276'><br/></div><div class='line' id='LC277'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">SkeletonStream</span><span class="p">.</span><span class="n">IsEnabled</span><span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC278'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Enable-SkeletonStream</span></div><div class='line' id='LC279'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC280'><br/></div><div class='line' id='LC281'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Register-ObjectEvent</span> <span class="n">-InputObject</span> <span class="nv">$Global:PwrActiveRecognizer</span> <span class="n">-EventName</span> <span class="n">SwipeLeftDetected</span> <span class="n">-SourceIdentifier</span> <span class="n">LeftHand</span> <span class="n">-Action</span> <span class="nv">$action</span> </div><div class='line' id='LC282'><span class="p">}</span></div><div class='line' id='LC283'><br/></div><div class='line' id='LC284'><span class="k">function</span> <span class="nb">Start-PowerPoint</span> <span class="p">{</span></div><div class='line' id='LC285'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">param</span><span class="p">(</span><span class="nv">$PathToPowerPointDeck</span><span class="p">)</span></div><div class='line' id='LC286'><br/></div><div class='line' id='LC287'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Application</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">-ComObject</span> <span class="n">powerpoint</span><span class="p">.</span><span class="n">application</span></div><div class='line' id='LC288'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Application</span><span class="p">.</span><span class="n">Presentations</span><span class="p">.</span><span class="n">Open</span><span class="p">(</span><span class="nv">$PathToPowerPointDeck</span><span class="p">)</span></div><div class='line' id='LC289'><br/></div><div class='line' id='LC290'><br/></div><div class='line' id='LC291'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[void][reflection.assembly]</span><span class="err">::</span><span class="n">loadwithpartialname</span><span class="p">(</span><span class="s2">&quot;system.windows.forms&quot;</span><span class="p">)</span></div><div class='line' id='LC292'><br/></div><div class='line' id='LC293'><br/></div><div class='line' id='LC294'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ipmo</span> <span class="n">PowerKinect</span></div><div class='line' id='LC295'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC296'><br/></div><div class='line' id='LC297'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-RightHandGesture</span> <span class="n">-action</span> <span class="p">{</span><span class="no">[system.windows.forms.sendkeys]</span><span class="err">::</span><span class="n">SendWait</span><span class="p">(</span><span class="s2">&quot;{RIGHT}&quot;</span><span class="p">)}</span></div><div class='line' id='LC298'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-LeftHandGesture</span> <span class="n">-action</span> <span class="p">{</span><span class="no">[system.windows.forms.sendkeys]</span><span class="err">::</span><span class="n">SendWait</span><span class="p">(</span><span class="s2">&quot;{LEFT}&quot;</span><span class="p">)}</span></div><div class='line' id='LC299'><span class="p">}</span></div><div class='line' id='LC300'><br/></div><div class='line' id='LC301'><span class="k">Function</span> <span class="nb">Get-KinectSpeechRecognizerEngine</span></div><div class='line' id='LC302'><span class="p">{</span></div><div class='line' id='LC303'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span></div><div class='line' id='LC304'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC305'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC306'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC307'>&nbsp;&nbsp;&nbsp;&nbsp;</div><div class='line' id='LC308'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Recognizers</span> <span class="p">=</span> <span class="no">[Microsoft.Speech.Recognition.SpeechRecognitionEngine]</span><span class="err">::</span><span class="n">InstalledRecognizers</span><span class="p">()</span></div><div class='line' id='LC309'><br/></div><div class='line' id='LC310'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Foreach</span> <span class="p">(</span><span class="nv">$Recognizer</span> <span class="k">in</span> <span class="nv">$Recognizers</span><span class="p">)</span></div><div class='line' id='LC311'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC312'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Verbose</span> <span class="p">(</span><span class="s2">&quot;Found &quot;</span> <span class="p">+</span> <span class="nv">$Recognizer</span><span class="p">.</span><span class="n">Name</span><span class="p">)</span></div><div class='line' id='LC313'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">If</span> <span class="p">(</span><span class="nv">$Recognizer</span><span class="p">.</span><span class="n">additionalinfo</span><span class="p">.</span><span class="n">trygetvalue</span><span class="p">(</span><span class="s2">&quot;Kinect&quot;</span><span class="p">,</span><span class="no">[ref]</span><span class="nv">$null</span><span class="p">)</span> <span class="o">-and</span> <span class="nv">$Recognizer</span><span class="p">.</span><span class="n">Culture</span><span class="p">.</span><span class="n">Name</span> <span class="o">-eq</span> <span class="s1">&#39;en-US&#39;</span><span class="p">)</span></div><div class='line' id='LC314'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC315'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Return</span> <span class="no">[Microsoft.Speech.Recognition.SpeechRecognitionEngine]</span><span class="nv">$Recognizer</span></div><div class='line' id='LC316'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC317'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC318'><br/></div><div class='line' id='LC319'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">Throw</span> <span class="s2">&quot;No Kinect Speech Recognition Engine Found&quot;</span></div><div class='line' id='LC320'><span class="p">}</span></div><div class='line' id='LC321'><br/></div><div class='line' id='LC322'><span class="k">Function</span> <span class="nb">Add-Grammar</span></div><div class='line' id='LC323'><span class="p">{</span></div><div class='line' id='LC324'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Param</span><span class="p">(</span></div><div class='line' id='LC325'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">[</span><span class="k">Parameter</span><span class="p">(</span><span class="k">Mandatory</span><span class="p">=</span><span class="nv">$true</span><span class="p">,</span><span class="k">ValueFromPipeline</span><span class="p">=</span><span class="nv">$true</span><span class="p">)]</span></div><div class='line' id='LC326'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[Microsoft.Speech.Recognition.SpeechRecognitionEngine]</span><span class="nv">$SpeechEngine</span><span class="p">,</span></div><div class='line' id='LC327'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[hashtable]</span><span class="nv">$Grammar</span><span class="p">,</span></div><div class='line' id='LC328'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[switch]</span><span class="nv">$passthru</span></div><div class='line' id='LC329'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">)</span></div><div class='line' id='LC330'><br/></div><div class='line' id='LC331'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$GrammarList</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Speech</span><span class="p">.</span><span class="n">Recognition</span><span class="p">.</span><span class="n">Choices</span></div><div class='line' id='LC332'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Foreach</span> <span class="p">(</span><span class="nv">$Key</span> <span class="k">in</span> <span class="nv">$Grammar</span><span class="p">.</span><span class="n">Keys</span><span class="p">)</span></div><div class='line' id='LC333'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC334'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$Pair</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Speech</span><span class="p">.</span><span class="n">Recognition</span><span class="p">.</span><span class="n">SemanticResultValue</span> <span class="n">-ArgumentList</span> <span class="nv">$Key</span><span class="p">,</span><span class="nv">$Grammar</span><span class="p">.</span><span class="nv">$Key</span></div><div class='line' id='LC335'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$GrammarList</span><span class="p">.</span><span class="n">Add</span><span class="p">(</span><span class="nv">$Pair</span><span class="p">)</span></div><div class='line' id='LC336'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Verbose</span> <span class="p">(</span><span class="s2">&quot;Added to Grammar List: $key&quot;</span><span class="p">)</span></div><div class='line' id='LC337'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC338'><br/></div><div class='line' id='LC339'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$GrammarBuilder</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Speech</span><span class="p">.</span><span class="n">Recognition</span><span class="p">.</span><span class="n">GrammarBuilder</span></div><div class='line' id='LC340'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$GrammarBuilder</span><span class="p">.</span><span class="n">Culture</span> <span class="p">=</span> <span class="nv">$SpeechEngine</span><span class="p">.</span><span class="n">RecognizerInfo</span><span class="p">.</span><span class="n">Culture</span></div><div class='line' id='LC341'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$GrammarBuilder</span><span class="p">.</span><span class="n">Append</span><span class="p">(</span><span class="nv">$GrammarList</span><span class="p">)</span></div><div class='line' id='LC342'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$FinalGrammar</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Speech</span><span class="p">.</span><span class="n">Recognition</span><span class="p">.</span><span class="n">Grammar</span> <span class="n">-ArgumentList</span> <span class="nv">$GrammarBuilder</span></div><div class='line' id='LC343'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$SpeechEngine</span><span class="p">.</span><span class="n">LoadGrammar</span><span class="p">(</span><span class="nv">$FinalGrammar</span><span class="p">)</span></div><div class='line' id='LC344'><br/></div><div class='line' id='LC345'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">If</span> <span class="p">(</span><span class="nv">$FinalGrammar</span><span class="p">.</span><span class="n">Loaded</span> <span class="o">-eq</span> <span class="nv">$false</span><span class="p">)</span></div><div class='line' id='LC346'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC347'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">throw</span> <span class="s2">&quot;Grammar Not Loaded for some reason&quot;</span></div><div class='line' id='LC348'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC349'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Elseif</span> <span class="p">(</span><span class="nv">$passthru</span><span class="p">)</span></div><div class='line' id='LC350'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC351'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$SpeechEngine</span></div><div class='line' id='LC352'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC353'><span class="p">}</span></div><div class='line' id='LC354'><br/></div><div class='line' id='LC355'><span class="k">Function</span> <span class="nb">Enable-AudioStream</span></div><div class='line' id='LC356'><span class="p">{</span></div><div class='line' id='LC357'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Param</span><span class="p">(</span></div><div class='line' id='LC358'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">[</span><span class="k">Parameter</span><span class="p">(</span><span class="k">Mandatory</span><span class="p">=</span><span class="nv">$true</span><span class="p">,</span><span class="k">ValueFromPipeline</span><span class="p">=</span><span class="nv">$true</span><span class="p">)]</span></div><div class='line' id='LC359'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[Microsoft.Speech.Recognition.SpeechRecognitionEngine]</span><span class="nv">$SpeechEngine</span></div><div class='line' id='LC360'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">)</span></div><div class='line' id='LC361'><br/></div><div class='line' id='LC362'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(!</span><span class="nv">$Global:PwrKinect</span><span class="p">.</span><span class="n">IsRunning</span><span class="p">)</span></div><div class='line' id='LC363'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC364'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Start-Kinect</span></div><div class='line' id='LC365'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC366'><br/></div><div class='line' id='LC367'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$audioFormat</span> <span class="p">=</span> <span class="nb">New-Object</span> <span class="n">Microsoft</span><span class="p">.</span><span class="n">Speech</span><span class="p">.</span><span class="n">AudioFormat</span><span class="p">.</span><span class="n">SpeechAudioFormatInfo</span> <span class="n">-ArgumentList</span> <span class="err">@</span><span class="p">(</span><span class="no">[microsoft.Speech.AudioFormat.EncodingFormat]</span><span class="err">::</span><span class="n">Pcm</span><span class="p">,</span> <span class="n">16000</span><span class="p">,</span> <span class="n">16</span><span class="p">,</span> <span class="n">1</span><span class="p">,</span> <span class="n">32000</span><span class="p">,</span> <span class="n">2</span><span class="p">,</span> <span class="nv">$null</span><span class="p">)</span></div><div class='line' id='LC368'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$SpeechEngine</span><span class="p">.</span><span class="n">SetInputToAudioStream</span><span class="p">(</span><span class="nv">$PwrKinect</span><span class="p">.</span><span class="n">AudioSource</span><span class="p">.</span><span class="n">Start</span><span class="p">(),</span><span class="nv">$audioFormat</span><span class="p">)</span></div><div class='line' id='LC369'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$SpeechEngine</span><span class="p">.</span><span class="n">RecognizeAsync</span><span class="p">(</span><span class="no">[Microsoft.Speech.Recognition.RecognizeMode]</span><span class="err">::</span><span class="n">Multiple</span><span class="p">)</span></div><div class='line' id='LC370'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Write-Verbose</span> <span class="s2">&quot;Speech Recognition Started&quot;</span></div><div class='line' id='LC371'><span class="p">}</span></div><div class='line' id='LC372'><br/></div><div class='line' id='LC373'><span class="k">Function</span> <span class="nb">Register-SpeechRecognitionEvents</span></div><div class='line' id='LC374'><span class="p">{</span></div><div class='line' id='LC375'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">Param</span> <span class="p">(</span></div><div class='line' id='LC376'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">[</span><span class="k">Parameter</span><span class="p">(</span><span class="k">Mandatory</span><span class="p">=</span><span class="nv">$true</span><span class="p">,</span><span class="k">ValueFromPipeline</span><span class="p">=</span><span class="nv">$true</span><span class="p">)]</span></div><div class='line' id='LC377'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[Microsoft.Speech.Recognition.SpeechRecognitionEngine]</span><span class="nv">$SpeechEngine</span><span class="p">,</span></div><div class='line' id='LC378'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="no">[switch]</span><span class="nv">$passthru</span></div><div class='line' id='LC379'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">)</span></div><div class='line' id='LC380'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Register-ObjectEvent</span> <span class="n">-InputObject</span> <span class="nv">$SpeechEngine</span> <span class="n">-EventName</span> <span class="n">SpeechRecognized</span> <span class="n">-SourceIdentifier</span> <span class="nv">$EventsourceName</span></div><div class='line' id='LC381'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">If</span> <span class="p">(</span><span class="nv">$passthru</span><span class="p">)</span></div><div class='line' id='LC382'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">{</span></div><div class='line' id='LC383'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">$SpeechEngine</span></div><div class='line' id='LC384'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">}</span></div><div class='line' id='LC385'><span class="p">}</span></div><div class='line' id='LC386'><br/></div><div class='line' id='LC387'><span class="nb">Export-ModuleMember</span> <span class="n">-Function</span> <span class="nb">Start-Kinect</span><span class="p">,</span> <span class="nb">Stop-Kinect</span><span class="p">,</span> <span class="nb">Enable-SkeletonStream</span><span class="p">,</span> <span class="nb">Disable-SkeletonStream</span><span class="p">,</span> <span class="nb">Add-RightHandGesture</span><span class="p">,</span> <span class="p">`</span></div><div class='line' id='LC388'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">Add-LeftHandGesture</span><span class="p">,</span> <span class="nb">Start-PowerPoint</span><span class="p">,</span> <span class="nb">Get-KinectSpeechRecognizerEngine</span><span class="p">,</span> <span class="nb">Enable-AudioStream</span><span class="p">,</span> <span class="nb">Register-SpeechRecognitionEvents</span></div></pre></div>
          </td>
        </tr>
      </table>
  </div>

          </div>
        </div>

        <a href="#jump-to-line" rel="facebox" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
        <div id="jump-to-line" style="display:none">
          <h2>Jump to Line</h2>
          <form accept-charset="UTF-8" class="js-jump-to-line-form">
            <input class="textfield js-jump-to-line-field" type="text">
            <div class="full-button">
              <button type="submit" class="button">Go</button>
            </div>
          </form>
        </div>

      </div>
    </div>
</div>

<div id="js-frame-loading-template" class="frame frame-loading large-loading-area" style="display:none;">
  <img class="js-frame-loading-spinner" src="https://a248.e.akamai.net/assets.github.com/images/spinners/octocat-spinner-128.gif?1360648843" height="64" width="64">
</div>


        </div>
      </div>
      <div class="context-overlay"></div>
    </div>

      <div id="footer-push"></div><!-- hack for sticky footer -->
    </div><!-- end of wrapper - hack for sticky footer -->

      <!-- footer -->
      <div id="footer">
  <div class="container clearfix">

      <dl class="footer_nav">
        <dt>GitHub</dt>
        <dd><a href="https://github.com/about">About us</a></dd>
        <dd><a href="https://github.com/blog">Blog</a></dd>
        <dd><a href="https://github.com/contact">Contact &amp; support</a></dd>
        <dd><a href="http://enterprise.github.com/">GitHub Enterprise</a></dd>
        <dd><a href="http://status.github.com/">Site status</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Applications</dt>
        <dd><a href="http://mac.github.com/">GitHub for Mac</a></dd>
        <dd><a href="http://windows.github.com/">GitHub for Windows</a></dd>
        <dd><a href="http://eclipse.github.com/">GitHub for Eclipse</a></dd>
        <dd><a href="http://mobile.github.com/">GitHub mobile apps</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Services</dt>
        <dd><a href="http://get.gaug.es/">Gauges: Web analytics</a></dd>
        <dd><a href="http://speakerdeck.com">Speaker Deck: Presentations</a></dd>
        <dd><a href="https://gist.github.com">Gist: Code snippets</a></dd>
        <dd><a href="http://jobs.github.com/">Job board</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Documentation</dt>
        <dd><a href="http://help.github.com/">GitHub Help</a></dd>
        <dd><a href="http://developer.github.com/">Developer API</a></dd>
        <dd><a href="http://github.github.com/github-flavored-markdown/">GitHub Flavored Markdown</a></dd>
        <dd><a href="http://pages.github.com/">GitHub Pages</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>More</dt>
        <dd><a href="http://training.github.com/">Training</a></dd>
        <dd><a href="https://github.com/edu">Students &amp; teachers</a></dd>
        <dd><a href="http://shop.github.com">The Shop</a></dd>
        <dd><a href="/plans">Plans &amp; pricing</a></dd>
        <dd><a href="http://octodex.github.com/">The Octodex</a></dd>
      </dl>

      <hr class="footer-divider">


    <p class="right">&copy; 2013 <span title="0.07601s from fe3.rs.github.com">GitHub</span>, Inc. All rights reserved.</p>
    <a class="left" href="https://github.com/">
      <span class="mega-icon mega-icon-invertocat"></span>
    </a>
    <ul id="legal">
        <li><a href="https://github.com/site/terms">Terms of Service</a></li>
        <li><a href="https://github.com/site/privacy">Privacy</a></li>
        <li><a href="https://github.com/security">Security</a></li>
    </ul>

  </div><!-- /.container -->

</div><!-- /.#footer -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/adminian/PowerKinect/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-icon mega-icon-normalscreen"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="mini-icon mini-icon-brightness"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="mini-icon mini-icon-exclamation"></span>
      Something went wrong with that request. Please try again.
      <a href="#" class="mini-icon mini-icon-remove-close ajax-error-dismiss"></a>
    </div>

    
    
    <span id='server_response_time' data-time='0.07677' data-host='fe3'></span>
    
  </body>
</html>

