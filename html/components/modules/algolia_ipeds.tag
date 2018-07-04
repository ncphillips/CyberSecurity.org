{% comment %}
Title: Algolia: Ipeds
Markup: {% this degree:"" cips:"" state:"" %}
Example: {% this degree:"deg_bach" cips:"" state:"SD" %}
Properties: <ul><li>degree <i>cert, deg_assc, deg_bach, deg_mast, deg_doct, cert_post_bach, cert_post_mast, other, or exclude property</i></li><li>cips <i>e.g. "42.0101", "42.0101, 42.2701, 42.2702, 42.2703, 42.2704", or exclude property</i></li><li>state <i>e.g. "AL", "SD" or exclude property</i></li><li><small><i>Exclude blank properties from Tag/Block</i></small></ul>
{% endcomment %}


<div class="algolia-container algolia-ipeds">

  <!-- Filters -->
  <div class="filters">

    <form class="filter-form">

      <div class="filter-title">Search Rankings</div>
      <div id="algolia-searchBox"></div>

      <div class="filter-title">Filter Options</div>
      <div class="filter-section js-target">

        <div class="filter-control js-toggle"></div>

        <div class="filter-category is-active">
          <div class="filter-label js-toggle-category">Degrees</div>
          <div class="filter-options" id="algolia-toggleList-degrees"></div>
        </div>

        <div class="filter-category">
          <div class="filter-label js-toggle-category">Location</div>
          <div class="filter-options" id="algolia-toggleList-address_state"></div>
        </div>

        <div class="filter-category">
          <div class="filter-label js-toggle-category">Institution Type</div>
          <div class="filter-options" id="algolia-toggleList-school_control"></div>
        </div>

        <div class="filter-category">
          <div class="filter-label js-toggle-category">School Type</div>
          <div class="filter-options" id="algolia-toggleList-distance_learning"></div>
        </div>

      </div>

      <div id="algolia-clearAll"></div>

    </form>

  </div>

  <!-- Title/Hits/Pagination -->
  <div class="results list js-children-toggle">

    <div id="algolia-currentRefinedValues"></div>

    <h3 class="header">

      {{ title | ternary: 'Schools' }}

      <div class="result-stats">
        <div class="result-count" id="algolia-count"></div>
      </div>

      <div class="btn-controls">
        <button type="button" class="btn-toggle js-collapse-all">Collapse All</button>
        <button type="button" class="btn-toggle js-expand-all">Expand All</button>
      </div>

    </h3>

    <div id="algolia-hits"></div>
    <div class="algolia-pagination" id="algolia-pagination"></div>

  </div>

</div>

<link href="https://cdn.jsdelivr.net/instantsearch.js/1/instantsearch.min.css" rel="stylesheet" type="text/css" />
<script src="https://cdn.jsdelivr.net/instantsearch.js/1/instantsearch.min.js"></script>

<script>

// Facet Refinements
var disjunctiveFacetsRefinements = {};

var cips = [{{ cips }}]; // e.g. ['42.0101', '42.2701', '42.2702', '42.2703', '42.2704']
{% if cips %}
  disjunctiveFacetsRefinements["completions.classification_code"] = cips
{% endif %}

{% if state %}
  disjunctiveFacetsRefinements["address.state"] = ["{{ state }}"];
{% endif %}

{% case degree %}
  {% when 'cert' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Certificate"];
  {% when 'deg_assc' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Associates Degree"];
  {% when 'deg_bach' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Bachelors Degree"];
  {% when 'deg_mast' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Masters Degree"];
  {% when 'deg_doct' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Doctoral Degree"];
  {% when 'cert_post_bach' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Post-Bachelors Certificate"];
  {% when 'cert_post_mast' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Post-Masters Certificate"];
  {% when 'other' %}
    disjunctiveFacetsRefinements["degrees.{{ degree }}"] = ["Other Degree"];
{% endcase %}


// Algoila Init
var algoliaIpeds = instantsearch({
  appId: '{{ site.algolia.api_id }}',
  apiKey: '{{ site.algolia.api_key }}',
  indexName: '{{ index }}',
  urlSync: false,
  searchParameters: {
    disjunctiveFacetsRefinements: disjunctiveFacetsRefinements,
    attributesToRetrieve: ['school_name', 'costs', 'headcount', 'address', 'rates', 'distance_learning', 'completions', 'degrees']
  }
});


// School Transform
function transformIped(item) {

  // Phone number
  item.address.phone = formatPhone(item.address.phone);

  // School Type
  if (item.distance_learning) {
    var types = [
      'Campus',
      'Online',
      'Both Online and Campus'
    ];
    var get_type = item.distance_learning.campus + item.distance_learning.online * 2;

    item.school_type = types[get_type - 1];
  }

  // Graduation Rate
  if (item.rates && item.rates.graduation) {
    item.rates.graduation = Math.round(item.rates.graduation);
  }

  // Acceptance Rate
  if (item.rates && item.rates.acceptance) {
    item.rates.acceptance = Math.round(item.rates.acceptance);
  }

  // Student Population
  if (item.headcount && item.headcount.grand_total) {
    item.headcount.grand_total = numberFormat(item.headcount.grand_total);
  }

  // Completions
  if (item.completions) {

    // Completions
    var completions = {
      'Certificate': [],
      'Associates Degree': [],
      'Bachelors Degree': [],
      'Post-Bachelors Certificate': [],
      'Masters Degree': [],
      'Post-Masters Certificate': [],
      'Doctoral Degree': []
    };

    for (var i = 0; i < item.completions.length; i++) {
      if (cips !== undefined && cips.length !== 0 && cips.indexOf(item.completions[i].classification_code) > -1) {
        if (item.completions[i].award_level in completions && completions[item.completions[i].award_level].indexOf(item.completions[i].classification_label) === -1) {
          completions[item.completions[i].award_level].push(item.completions[i].classification_label);
        }
      } else {
        if (item.completions[i].award_level in completions && completions[item.completions[i].award_level].indexOf(item.completions[i].classification_label) === -1) {
          completions[item.completions[i].award_level].push(item.completions[i].classification_label);
        }
      }
    }

    var completions_markup = '';

    for (var key in completions) {
      if (completions[key].length > 0) {
        completions[key] = uniq(completions[key]);

        for (var i = 0; i < completions[key].length; i++) {
          var deg = key.replace(' Degree', '');
          completions_markup += '<li itemprop="itemOffered"><em>' + deg + '</em> of ' + completions[key][i] + '</li>';
        }
      }
    }

    item.helper_completions = completions_markup;
  }

  return item;
}


// Helper: Unique Array Item
function uniq(a) {
  return a.sort().filter(function(item, pos, ary) { return !pos || item != ary[pos - 1]; });
}


// Helper: Format Phone
function formatPhone(str) {
  return str.replace(/\D/g, '').substring(0, 10).replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
}


// Helper: Format Number
function numberFormat(num) {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}


// Helper: Capitlized Words
function capitlizedWords(str) {
  return str.replace(/(?:^|\s)\S/g, function(a) {
    return a.toUpperCase();
  });
};


// Helper: Format Refined Tag Values
function formatRefineValues(item) {
  switch (item.attributeName) {
    case 'address.state':
      item = stateAbbrToName(item);
    break;
    case 'distance_learning.campus':
      item.name = (item.name == '1') ? 'Campus' : '';
    break;
    case 'distance_learning.online':
      item.name = (item.name == '1') ? 'Online' : '';
    break;
  }

  return item;
}


// Helper: Min GPA Label
function minGPALabel(item) {
  var gpa = {
    "0": "Not Specified",
    "1": "1.0",
    "2": "2.0",
    "3": "3.0",
    "4": "4.0",
  };

  item.name = gpa[item.name] ? gpa[item.name] : item.name;
  item.highlighted = item.name;

  return item;
}


// Helper: State Abbreviation to Name
function stateAbbrToName(item) {
  var states = {
    "AA": "Armed Forces Americas",
    "AB": "Alberta",
    "AE": "Armed Forces Africa/Canada/Europe/Middle East",
    "AK": "Alaska",
    "AL": "Alabama",
    "AP": "Armed Forces Pacific",
    "AR": "Arkansas",
    "AS": "American Samoa",
    "AZ": "Arizona",
    "BC": "British Columbia",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DC": "District Of Columbia",
    "DE": "Delaware",
    "FL": "Florida",
    "FM": "Federated States Of Micronesia",
    "GA": "Georgia",
    "GU": "Guam",
    "HI": "Hawaii",
    "IA": "Iowa",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "MA": "Massachusetts",
    "MB": "Manitoba",
    "MD": "Maryland",
    "ME": "Maine",
    "MH": "Marshall Islands",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MO": "Missouri",
    "MP": "Northern Mariana Islands",
    "MS": "Mississippi",
    "MT": "Montana",
    "NB": "New Brunswick",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "NE": "Nebraska",
    "NF": "Newfoundland and Labrador",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NL": "Newfoundland and Labrador",
    "NM": "New Mexico",
    "NS": "Nova Scotia",
    "NT": "Northwest Territories",
    "NU": "Nunavut",
    "NV": "Nevada",
    "NY": "New York",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "ON": "Ontario",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "PE": "Prince Edward Island",
    "PR": "Puerto Rico",
    "PW": "Palau",
    "QC": "Québec",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "SK": "Saskatchewan",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VA": "Virginia",
    "VI": "Virgin Islands",
    "VT": "Vermont",
    "WA": "Washington",
    "WI": "Wisconsin",
    "WV": "West Virginia",
    "WY": "Wyoming",
    "YT": "Yukon"
  };

  item.name = states[item.name];
  item.highlighted = item.name;

  return item;
}


{% raw %}


// Custom Classes
var dropdownClasses = {
  root: 'filter-expand',
  header: 'filter-expand-header',
  body: 'filter-expand-body',
  item: 'filter-expand-item',
  active: 'active',
  count: 'filter-count'
};
var toggleClasses = {
  count: 'filter-count',
  active: 'active'
};


// Template
var templateIped = '\
<div class="item js-target">\
  <h4 class="title js-toggle">\
    {{school_name}}\
    {{#avg}}<span class="amount">${{avg}}</span>{{/avg}}\
    <svg aria-hidden="true" class="icon-plus-minus" width="29" height="29" viewBox="0 0 29 29" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><ellipse class="circle" cx="14.5" cy="14.5" rx="14.5" ry="14.5"></ellipse><path class="plus" d="M8.833 13.171h4.037V9.135h3.035v4.036h4.036v3.035h-4.036v4.036H12.87v-4.036H8.833z"></path><path class="minus" d="M8.833 13.171h11.108v3.035H8.833z"></path></g></svg>\
  </h4>\
  <div class="content">\
    <h5>Information</h5>\
    <p>\
    {{#helper_distance_learning}}<strong>School Type:</strong> {{helper_distance_learning}}<br />{{/helper_distance_learning}}\
    {{#costs.in_state_tuition}}<strong>In-state Tuition:</strong> ${{costs.in_state_tuition}}<br />{{/costs.in_state_tuition}}\
    {{#costs.out_state_tuition}}<strong>Out-of-state Tuition:</strong> ${{costs.out_state_tuition}}<br />{{/costs.out_state_tuition}}\
    {{#rates.graduation}}<strong>Graduation Rate:</strong> {{rates.graduation}}%<br />{{/rates.graduation}}\
    {{#rates.acceptance}}<strong>Acceptance Rate:</strong> {{rates.acceptance}}%<br />{{/rates.acceptance}}\
    {{#headcount.grand_total}}<strong>Student Population:</strong> {{headcount.grand_total}}<br />{{/headcount.grand_total}}\
    {{#rates.student_faculty_ratio}}<p><strong>Student-Faculty Ratio:</strong> {{rates.student_faculty_ratio}} to 1<br />{{/rates.student_faculty_ratio}}\
    </p>\
    {{#address.street}}\
      <h5>Address &amp; College Info</h5>\
      <p>\
        {{address.street}}<br />\
        {{#address.city}}{{address.city}},{{/address.city}}\
        {{#address.state}} {{address.state}}{{/address.state}}\
        {{#address.zip}} {{address.zip}}<br />{{/address.zip}}\
        {{#address.email}}{{address.email}}<br />{{/address.email}}\
        {{#address.phone}}{{address.phone}}{{/address.phone}}\
      </p>\
    {{/address.street}}\
    {{#helper_completions}}\
    <h5>Programs Available</h5>\
    <ul>{{{helper_completions}}}</ul>\
    {{/helper_completions}}\
    {{#url.institution}}<a class="link-tertiary" href="{{url.institution}}" target="_blank" rel="nofollow">School Information</a>{{/url.institution}}\
  </div>\
</div>';


// Result Count
algoliaIpeds.addWidget(
  instantsearch.widgets.stats({
    container: '.algolia-ipeds #algolia-count',
    templates: {
      body: '{{nbHits}} Results'
    }
  })
);


// Pagination
algoliaIpeds.addWidget(
  instantsearch.widgets.pagination({
    container: '.algolia-ipeds #algolia-pagination',
    scrollTo: '.algolia-ipeds',
    labels: {
      first: 'First',
      previous: 'Previous',
      next: 'Next',
      last: 'Last'
    },
    padding: 2,
    cssClasses: {
      root: 'pagination',
      disabled: 'pagination-disabled',
      active: 'pagination-active'
    }
  })
);


// Filters: clear all
algoliaIpeds.addWidget(
  instantsearch.widgets.clearAll({
    container: '.algolia-ipeds #algolia-clearAll',
    cssClasses: {
      link: 'btn btn-secondary',
    },
    templates: {
      link: 'Clear All Filters'
    },
    autoHideContainer: true
  })
);


// Results
algoliaIpeds.addWidget(
  instantsearch.widgets.hits({
    container: '.algolia-ipeds #algolia-hits',
    templates: {
      empty: 'Sorry, no results found.',
      item: templateIped
    },
    transformData: {
      item: transformIped
    },
    hitsPerPage: 20
  })
);


// Search by name/city
algoliaIpeds.addWidget(
  instantsearch.widgets.searchBox({
    container: '.algolia-ipeds #algolia-searchBox',
    autofocus: false
  })
);


// Current Refinement Values
algoliaIpeds.addWidget(
  instantsearch.widgets.currentRefinedValues({
    container: '.algolia-ipeds #algolia-currentRefinedValues',
    clearAll: false,
    transformData: {
      item: formatRefineValues
    },
    templates: {
      header: 'Filtering By:'
    },
    attributes: [
      { name: 'address.state', },
      { name: 'school_control', },
      { name: 'distance_learning.campus', },
      { name: 'distance_learning.online', },
      { name: 'degrees.deg_assc', },
      { name: 'degrees.cert', },
      { name: 'degrees.cert_post_bach', },
      { name: 'degrees.cert_post_mast', },
      { name: 'degrees.deg_bach', },
      { name: 'degrees.deg_doct', },
      { name: 'degrees.deg_mast', },
      { name: 'degrees.other', },
    ],
    onlyListedAttributes: true
  })
);

{% endraw %}


// Filters: Toggles
var toggleFacets = {
  "address.state": {
    "AK": "Alaska",
    "AL": "Alabama",
    "AR": "Arkansas",
    "AZ": "Arizona",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DC": "District Of Columbia",
    "DE": "Delaware",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "IA": "Iowa",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "MA": "Massachusetts",
    "MD": "Maryland",
    "ME": "Maine",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MO": "Missouri",
    "MS": "Mississippi",
    "MT": "Montana",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "NE": "Nebraska",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NV": "Nevada",
    "NY": "New York",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VA": "Virginia",
    "VT": "Vermont",
    "WA": "Washington",
    "WI": "Wisconsin",
    "WV": "West Virginia",
    "WY": "Wyomin"
  },
  "degrees.cert": "Certificate",
  "degrees.deg_assc": "Associates Degree",
  "degrees.deg_bach": "Bachelors Degree",
  "degrees.deg_mast": "Masters Degree",
  "degrees.deg_doct": "Doctoral Degree",
  "degrees.cert_post_bach": "Post-Bachelors Certificate",
  "degrees.cert_post_mast": "Post-Masters Certificate",
  "school_control" : {
    "Private (For Profit)": "",
    "Private (Non Profit)": "",
    "Public": "",
  },
  "distance_learning.campus" : {
    "1": "Campus",
  },
  "distance_learning.online" : {
    "1": "Online",
  }
};

// Facet Grouping
facetGroupings = {};

// Setup Groupings
for (var facet in toggleFacets) {
  var parent = facet.indexOf('.') > 0 ? facet.substr(0, facet.indexOf('.')) : facet;

  // New Group
  if (!facetGroupings[parent]) {
    facetGroupings[parent] = { [facet]: toggleFacets[facet] };
    continue;
  }

  // Existing Group Append
  facetGroupings[parent][facet] = toggleFacets[facet];
}

// Loop Facet Groupings
for (var grouping in facetGroupings) {
  var groupCount = Object.keys(facetGroupings[grouping]).length;

  // Empty
  if (groupCount === 0) {
    continue;
  }

  // Container
  var groupTitle = groupCount === 1 ? Object.keys(facetGroupings[grouping])[0] : grouping;
  var container  = 'algolia-toggleList-' + groupTitle.replace(/\.|\s/gi, '_');
  var facets     = groupCount === 1 ? { [groupTitle]: facetGroupings[grouping][Object.keys(facetGroupings[grouping])[0]] } : facetGroupings[grouping];

  // Loop Facet Groupings
  for (var facet in facets) {

    // Facet with Single Filter
    if (typeof facets[facet] === 'string' || facets[facet] instanceof String) {

      // Create Child DOM Element.
      var toggle = document.createElement('div');
      toggle.id  = 'algolia-toggle-' + facet.replace(/\.|\s/gi, '_');

      // Append Dom Child Element to Selector Container.
      document.getElementById(container).appendChild(toggle);

      // Setup Toggle
      algoliaIpeds.addWidget(
        instantsearch.widgets.toggle({
          container: '.algolia-ipeds #' + container + ' #' + toggle.id,
          attributeName: facet,
          label: facets[facet],
          values: {
            on: facets[facet]
          },
          cssClasses: toggleClasses
        })
      );

      continue;
    }

    // Facets with Multiple Filters
    for (var filter in facets[facet]) {
      var toggle = document.createElement('div');
      toggle.id  = 'algolia-toggle-' + (facet + '_' + filter).replace(/\.|\s|\(|\)/gi, '_').toLowerCase();

      // Append Dom Child Element to Selector Container.
      document.getElementById(container).appendChild(toggle);

      // Setup Toggle
      algoliaIpeds.addWidget(
        instantsearch.widgets.toggle({
          container: '.algolia-ipeds #' + container + ' #' + toggle.id,
          attributeName: facet,
          label: facets[facet][filter] ? facets[facet][filter] : filter,
          values: {
            on: filter
          },
          cssClasses: toggleClasses
        })
      );
    }
  }
}

// Algolia Start
algoliaIpeds.start()

</script>
