{shared{

  type 'a config = {
    value : [ `Default of 'a | `Constant of 'a ] option;
    label : string option;
    a : Html5_types.div_attrib Eliom_content.Html5.F.attrib list;
  }

  type ('w, 'a) pathed_config =
    | Pathed_config : ('w, 'a, _, 'c) Deriving_Typerepr.p * 'c config -> ('w, 'a) pathed_config

  val (-->) : ('w, 'a, _, 'c) Deriving_Typerepr.p -> 'c config -> ('w, 'a) pathed_config

  (** {1 Generate Eliom form content from runtime type representation} *)
  val content :
    'a Deriving_Typerepr.t ->
    ?configs:((_, 'a) pathed_config list) ->
    [ `One of 'a Eliom_parameter.caml ] Eliom_parameter.param_name ->
    Html5_types.form_content Eliom_content.Html5.F.elt

  (** Name of the installed CSS file *)
  val css_filename : string

  (** HTML class names used to generate form content *)
  val form_outmost_class : string
  val form_class : string
  val atomic_class : string
  val option_class : string
  val option_selector_class : string
  val option_content_class : string
  val sum_class : string
  val sum_selector_class : string
  val sum_content_class : string
  val sum_case_class : string
  val sum_case_marker_class : string -> string
  val tuple_class : string
  val record_class : string
  val record_field_marker_class : string -> string
  val marker_class : string
  val selector_snippet : string
  val content_snippet : string
  val list_class : string
  val list_item_class : string
  val button_add_class : string
  val button_remove_class : string
  val label_class : string
}}
