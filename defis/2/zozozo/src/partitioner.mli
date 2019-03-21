(* Module destiné à une grosse partie du préprocessing de la feuille
   de calcul :

   1- extractions de toutes les formules


   2- Découpage de la feuille en plusieurs fichiers selon 2 critères
   (nbre max de fichiers et taille minimale des fichiers)

   Le découpage du fichier est réalisé de sorte à partager
   équitablement le travail entre eux (dans l'optique de
   parallélisation) et entre les lignes. La quantité de travail est
   mesurée par ligne de la sorte :

   - formule contenue dans la ligne = + 2 / formule

   - formule dépendant de la ligne = + nbre de cases concernées dans
   la ligne

   Pour prendre en compte les futures changements, et ne pas devoir
   créer des regions "at run time", le fichier user.txt est pris en
   compte dans l'analyse.


 *)

open Ast

type id = int
type area = int * int
type regs
type regions = {regs : regs ; r_to_pos : pos -> id  }

val compute_regions : string -> int -> regions

val get_region_area : regions -> id -> int * int

val get_region_data : regions -> id -> Regiondata.t

val pos_to_region : regions -> pos -> id

val regions_within : regions -> pos -> pos -> id list

val number_regions : regions -> int

val regions_fold : (id -> area -> 'b -> 'b) -> regions -> 'b -> 'b

val compute_regions : string -> string -> int -> int -> ((pos * is_formula content) list * regions)

val cut_file_into_regions : string -> regions -> unit

val free_all : regions -> unit

val recombine_regions : string -> regions -> unit
